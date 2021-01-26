<script>
  import { tick, onMount, onDestroy } from 'svelte';
  import { catchError, concatMap, switchMap, filter } from 'rxjs/operators';
  import { fromEvent, of, EMPTY } from 'rxjs';
  import { fromPromise } from 'rxjs/internal-compatibility';
  import { BaseUrl } from 'src/lib/constants';
  import { T } from 'src/lib/locale';
  import Form from 'src/lib/form/form';
  import { SObject } from 'src/lib/sobject';
  import { ButtonType, ButtonId } from 'src/components/ui/button/types';
  import TreeView from 'src/components/ui/tree-view';
  import { validation } from './validation';

  import Button from 'src/components/ui/button/flat-button';
  import FloatNumberInput from 'src/components/ui/float-input/number-input';
  import FloatTextInput from 'src/components/ui/float-input/text-input';
  import Error from 'src/components/ui/error';
  import SC from 'src/components/set-common';
  import { errorSection } from 'src/lib/debug';
  import BackIcon from 'src/icons/back24x16.svelte';
  import { Role } from '../types';
  import { LoginInfo } from 'src/store/login-info';
  import { NotifyListener } from 'src/store/notify-listener';
  import { SkyLogStore } from 'src/store/skylog';

  // Props
  export let view;
  export let menuPath;
  export let store;
  export let backCallback;
  export let detailTitle = '';

  // Observable
  const { hasAnyDeletedRecord$, deleteRunning$, saveRunning$, isReadOnlyMode$, isUpdateMode$ } = view;

  const { dataList$ } = store;

  // Refs
  let codeRef;
  let scRef;

  let btnSaveRef;
  let btnUpdateRef;
  let orgTreeRef;

  // Other vars
  let selectedData;
  let saveOrUpdateSub;
  let dataChanged;
  /**
   * Reset form (reset input and errors)
   * @param {none}
   * @return {Form}. New Form
   */
  const resetForm = () => {
    return new Form(new Role());
  };
  let form = resetForm();
  let beforeForm;

  // ============================== EVENT HANDLE ==========================
  /**
   * Event handle for Add New button.
   * @param {event} Mouse click event.
   * @return {void}.
   */
  const onAddNew = (event) => {
    // verify permission
    view.verifyAddNewAction(event.currentTarget.id, scRef).then((_) => {
      // if everything is OK, call the action
      doAddNew();
    });
  };

  /**
   * Event handle for Edit button.
   * @param {event} Mouse click event.
   * @return {void}.
   */
  const onEdit = (event) => {
    // verify permission
    view.verifyEditAction(event.currentTarget.id, scRef, selectedData.name).then((_) => {
      // just switch to edit mode
      isReadOnlyMode$.next(false);
      tick().then(() => {
        // the moving focus to the first element
        codeRef.focus();
      });
    });
  };

  /**
   * Event handle for Delete button.
   * @param {event} Mouse click event.
   * @return {void}.
   */
  const onDelete = (event) => {
    // verify permission
    view.verifyDeleteAction(event.currentTarget.id, scRef, selectedData.name).then((_) => {
      // if everything is OK, call the action
      view.doDelete(selectedData.id, scRef.snackbarRef(), doAddNew);
    });
  };

  /**
   * Event handle for View Config button.
   * @param {event} Mouse click event.
   * @return {void}.
   */
  const onViewConfig = (event) => {
    view.showViewConfigModal(event.currentTarget.id, scRef);
  };

  /**
   * Event handle for Trash Restore button.
   * @param {event} Mouse click event.
   * @return {void}.
   */
  const onTrashRestore = (event) => {
    view.showTrashRestoreModal(event.currentTarget.id, false, scRef);
  };

  /**
   * Event handle for View Log button.
   * @param {event} Mouse click event.
   * @return {void}.
   */
  const onViewLog = (event) => {
    view.showViewLogModal(event.currentTarget.id, scRef);
  };

  const onCheckOrgTree = (event) => {
    form.errors.clear('orgId');
    form.errors.errors = { ...form.errors.errors };
  };
  // ============================== //EVENT HANDLE ==========================

  // ============================== CLIENT VALIDATION ==========================
  /**
   * Client validation and check for no data change.
   * @param {none}
   * @return {boolean}. true if all of things are valid, false: otherwise
   */
  const validate = () => {
    preprocessData();

    // client validation
    form.errors.errors = form.recordErrors(validation(form));
    if (form.errors.any()) {
      return false;
    }

    // check for data change
    if ($isUpdateMode$) {
      dataChanged = view.checkObjectChange(beforeForm, SObject.clone(form), scRef.snackbarRef());
      if (!dataChanged) {
        return false;
      }
    }

    return true;
  };
  // ============================== //CLIENT VALIDATION ==========================

  // ============================== FUNCTIONAL ==========================
  /**
   * Add new add. Called by onAddNew event handle
   * @param {none}
   * @return {void}.
   */
  const doAddNew = () => {
    // reset status flag
    isReadOnlyMode$.next(false);
    isUpdateMode$.next(false);
    view.selectedData$.next(null);

    // reset form
    form = resetForm();

    // moving focus to the first element after DOM updated
    tick().then(() => {
      codeRef.focus();
    });
  };

  /**
   * Save or update form. Called by onSave and onUpdate event handle
   * @param {ob$} Observable event of the button click or shortcut key(fromEvent)
   * @return {void}.
   */
  const doSaveOrUpdate = (ob$) => {
    saveOrUpdateSub = ob$
      .pipe(
        filter((_) => validate()) /* filter if form pass client validation */,
        concatMap((_) =>
          fromPromise(
            /* verify permission*/
            view.verifySaveAction($isUpdateMode$ ? ButtonId.update : ButtonId.save, scRef),
          ).pipe(
            catchError((error) => {
              return of(error);
            }),
          ),
        ),
        filter((value) => value !== 'fail') /* filter if pass verify permission*/,
        switchMap((_) => {
          /* submit data to API server*/
          saveRunning$.next(true);
          return form.post(BaseUrl.SYSTEM, 'role').pipe(
            catchError((error) => {
              return of(error);
            }),
          );
        }),
      )
      .subscribe({
        /* do something after form submit*/
        next: (res) => {
          if (res.response && res.response.data) {
            // if error
            if (res.response.data.field) {
              form.errors.errors = form.recordErrors(res.response.data);
            } else {
              scRef.snackbarRef().showUnknownError(res.response.data.message || res.response.data);
            }
          } else {
            // success
            if ($isUpdateMode$) {
              SkyLogStore.save(selectedData.name, { action: 'EDIT', payload: dataChanged }).subscribe();
              // update
              scRef.snackbarRef().showUpdateSuccess();
              if (!window.isSmartPhone) {
                view.needSelectId$.next(selectedData.id);
              }
            } else {
              // save
              scRef.snackbarRef().showSaveSuccess();
              doAddNew();
            }
          }
          saveRunning$.next(false);
        },
        error: (error) => {
          errorSection('Role - doSaveOrUpdate', error);
          saveRunning$.next(false);
        },
      });
  };

  const doSelect = (data) => {
    selectedData = data;
    if (selectedData) {
      isReadOnlyMode$.next(true);
      isUpdateMode$.next(true);
      form = new Form({
        ...selectedData,
      });
      orgTreeRef && orgTreeRef.checkNodeById(selectedData.orgId);
      // save init value for checking data change
      beforeForm = SObject.clone(form);
    }
  };
  // ============================== //FUNCTIONAL ==========================

  // ============================== REACTIVE ==========================
  // Monitoring selected data from other users
  // When other users edit on the same data, display a confirmation of the change with the current user
  view.selectedData$
    .pipe(
      switchMap((it) => {
        if (!it) return EMPTY;
        return NotifyListener.payload$.pipe(
          filter((p) => {
            return (
              p &&
              form.id &&
              p.table === view.tableName &&
              p.data.updatedBy != LoginInfo.getUserId() &&
              p.data.id === it.id
            );
          }),
        );
      }),
    )
    .subscribe(async (res) => {
      view.doNotifyConflictData(form, res.data, view.selectedData$.value.id, $isReadOnlyMode$, scRef);
    });

  // when user click on work list. load selected data to the right form
  const selectDataSub = view.selectedData$.subscribe((data) => {
    doSelect(data);
  });
  // ============================== //REACTIVE ==========================

  // ============================== HELPER ==========================
  const preprocessData = () => {
    const checkedIds = orgTreeRef.getCheckedIds(true);
    if (checkedIds && checkedIds.length > 0) {
      form.orgId = checkedIds[0];
    } else {
      delete form.orgId;
    }
  };
  // ============================== // HELPER ==========================
  // ============================== HOOK ==========================
  /**
   * onMount Hook.
   * @param {none}
   * @return {void}.
   */
  onMount(() => {
    // reset form
    doAddNew();
    // Capture hot key (Ctrl - S) for save or update
    const controlS$ = fromEvent(document, 'keydown').pipe(
      filter((e) => {
        if (e.keyCode == 83 && (navigator.platform.match('Mac') ? e.metaKey : e.ctrlKey)) {
          e.preventDefault();
          if (!$isReadOnlyMode$) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }),
    );
    doSaveOrUpdate(controlS$);
  });

  /**
   * oDestroy Hook. Release subscription
   * @param {none}
   * @return {void}.
   */
  onDestroy(() => {
    selectDataSub.unsubscribe();
    if (saveOrUpdateSub) {
      saveOrUpdateSub.unsubscribe();
    }
  });

  /**
   * Use save or update action directive. Register click event for Save / Update button
   * @param {none}
   * @return {void}.
   */
  const useSaveOrUpdateAction = {
    register(component, param) {
      doSaveOrUpdate(fromEvent(component, 'click'));
    },
  };
  // ============================== //HOOK ==========================
</script>

<!--Invisible Element-->
<SC bind:this={scRef} {view} {menuPath} />
<!--//Invisible Element-->

<!--Form navigation controller-->
{#if window.isSmartPhone}
  <section class="view-navigation-controller">
    <div class="view-navigation-controller__arrow" on:click={() => backCallback && backCallback()}>
      <BackIcon />
    </div>

    <div title={detailTitle} class="view-navigation-controller__title">{detailTitle}</div>

  </section>
{/if}
<!--//Form navigation controller-->

<!--Form controller-->
<section class="view-content-controller">
  {#if view.isRendered(ButtonId.addNew)}
    <Button btnType={ButtonType.addNew} on:click={onAddNew} disabled={view.isDisabled(ButtonId.addNew)} />
  {/if}

  {#if view.isRendered(ButtonId.save, !$isUpdateMode$)}
    <Button
      action={useSaveOrUpdateAction}
      bind:this={btnSaveRef}
      btnType={ButtonType.save}
      disabled={view.isDisabled(ButtonId.save, form.errors.any())}
      running={$saveRunning$} />
  {/if}

  {#if view.isRendered(ButtonId.edit, $isReadOnlyMode$ && $isUpdateMode$)}
    <Button btnType={ButtonType.edit} on:click={onEdit} disabled={view.isDisabled(ButtonId.edit)} />
  {/if}

  {#if view.isRendered(ButtonId.update, !$isReadOnlyMode$ && $isUpdateMode$)}
    <Button
      action={useSaveOrUpdateAction}
      bind:this={btnUpdateRef}
      btnType={ButtonType.update}
      disabled={view.isDisabled(ButtonId.update, form.errors.any())}
      running={$saveRunning$} />
  {/if}

  {#if view.isRendered(ButtonId.delete, $isUpdateMode$)}
    <Button
      btnType={ButtonType.delete}
      on:click={onDelete}
      disabled={view.isDisabled(ButtonId.delete)}
      running={$deleteRunning$} />
  {/if}

  {#if view.isRendered(ButtonId.config)}
    <Button btnType={ButtonType.config} on:click={onViewConfig} disabled={view.isDisabled(ButtonId.config)} />
  {/if}

  {#if view.isRendered(ButtonId.trashRestore, $hasAnyDeletedRecord$)}
    <Button
      btnType={ButtonType.trashRestore}
      on:click={onTrashRestore}
      disabled={view.isDisabled(ButtonId.trashRestore)} />
  {/if}

  {#if view.isRendered(ButtonId.viewLog)}
    <Button btnType={ButtonType.viewLog} on:click={onViewLog} disabled={view.isDisabled(ButtonId.viewLog)} />
  {/if}
</section>
<!--//Form controller-->

<!--Main content-->
<section class="view-content-main">
  <form class="form" on:keydown={(event) => form.errors.clear(event.target.name)}>
    <div class="row">
      <div class="col-xs-24 col-sm-12">
        <!-- Code -->
        <div class="row" style="grid-column-gap:0">
          <div class="col-24">
            <FloatTextInput
              placeholder={T('SYS.LABEL.CODE')}
              name="code"
              disabled={$isReadOnlyMode$}
              bind:value={form.code}
              bind:this={codeRef} />
            <Error {form} field="code" />
          </div>
        </div>
        <!-- // Code -->

        <!-- Name -->
        <div class="row " style="grid-column-gap:0">
          <div class="col-24">
            <FloatTextInput
              placeholder={T('SYS.LABEL.NAME')}
              name="name"
              disabled={$isReadOnlyMode$}
              bind:value={form.name} />
            <Error {form} field="name" />
          </div>
        </div>
        <!-- // Name -->

        <!-- Sort -->
        <div class="row " style="grid-column-gap:0">
          <div class="col-24">
            <FloatNumberInput
              placeholder={T('SYS.LABEL.SORT')}
              name="sort"
              disabled={$isReadOnlyMode$}
              bind:value={form.sort} />
            <Error {form} field="sort" />
          </div>
        </div>
        <!-- // Sort -->
      </div>
      <div class="default-border col-xs-24 col-sm-12">
        <TreeView
          on:check={onCheckOrgTree}
          bind:this={orgTreeRef}
          id={'orgTree' + view.getViewName() + 'Id'}
          data={$dataList$}
          disabled={$isReadOnlyMode$}
          radioType="all">
          <div slot="label" class="label">{T('SYS.LABEL.ORG')}:</div>
        </TreeView>
        {#if form.errors.has('orgId')}
          <span class="error">{form.errors.get('orgId')}</span>
        {/if}
      </div>
    </div>
  </form>
</section>
<!--//Main content-->
