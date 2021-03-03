<script>
  import { onDestroy } from 'svelte';
  import Item from './role-control-item.svelte';
  import Button from 'src/components/ui/button/flat-button';
  import { ButtonType, ButtonId } from 'src/components/ui/button/types';
  import SC from 'src/components/set-common';
  import { catchError, concatMap, switchMap, filter } from 'rxjs/operators';
  import { fromEvent, of } from 'rxjs';
  import { fromPromise } from 'rxjs/internal-compatibility';

  export let view;
  export let next$;
  export let role;
  export let orgMenuList;
  export let store;
  export let menuPath;

  let scRef, saveOrUpdateSub;
  let changedRoleDetails, changedRoleControlDetails;
  let postData;
  const { saveRunning$, isReadOnlyMode$, isUpdateMode$ } = view;

  isUpdateMode$.next(true);

  const onBack = () => {
    next$.next(false);
  };

  const useSaveOrUpdateAction = {
    register(component, param) {
      doSaveOrUpdate(fromEvent(component, 'click'));
    },
  };

  const validate = () => {
    // check for data change
    if ($isUpdateMode$) {
      changedRoleDetails = [];
      changedRoleControlDetails = [];
      for (let i = 0; i < store.roleDetails.length; i++) {
        changedRoleDetails.push(
          view.checkObjectChange(store.beforeRoleDetails[i], store.roleDetails[i]),
        );
        changedRoleControlDetails.push(
          view.checkObjectArrayChange(
            store.beforeRoleControlDetails[i],
            store.roleControlDetails[i],
            
          ),
        );
      }

      if (
        changedRoleDetails.filter((it) => it === null).length === changedRoleDetails.length &&
        changedRoleControlDetails.filter((it) => it === null).length === changedRoleControlDetails.length
      ) {
        scRef.snackbarRef().showNoDataChange();
        return false;
      }
    }

    postData = [];
    for (let i = 0 ; i < store.roleDetails.length ; i++) {
      if (changedRoleDetails[i] || changedRoleControlDetails[i]) {
        postData.push({
          ...store.roleDetails[i],
          menuId: orgMenuList[i].menuId,
          roleId: role.id,
          depId: orgMenuList[i].parentId,
          roleControlItems: changedRoleControlDetails[i]
        });
      }
    }

    return true;
  };

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
          /*Call grpc on server*/
          saveRunning$.next(true);

          return fromPromise(store.grpcUpsert(postData)).pipe(
            catchError((error) => {
              return of({ hasError: true, error });
            }),
          );
        }),
      )
      .subscribe({
        /* do something after form submit*/
        next: (res) => {
          if (res.hasError) {
            log.error(res.error);
            //error occured
            // form.errors.errors = form.recordErrors(res.error);
          } else {
            // // success
            // setTimeout(() => {
            //   dispatch('callback', res.toObject().id);
            // }, 2000);
            // if ($isUpdateMode$) {
            //   SkyLogStore.save(selectedData.name, { action: 'EDIT', payload: dataChanged });
            //   // update
            //   scRef.snackbarRef().showUpdateSuccess();
            //   if (!window.isSmartPhone) {
            //     view.needSelectId$.next(selectedData.id);
            //   }
            // } else {
            //   // save
            //   scRef.snackbarRef().showSaveSuccess();
            //   doAddNew();
            // }
          }

          saveRunning$.next(false);
        },
        error: (error) => {
          log.errorSection('Role Detail form', error);
          saveRunning$.next(false);
        },
      });
  };

  const onEdit = (event) => {
    // verify permission
    view.verifyEditAction(event.currentTarget.id, scRef, selectedData.name).then((_) => {
      // just switch to edit mode
      isReadOnlyMode$.next(false);
    });
  };

  const onViewConfig = (event) => {
    view.showViewConfigModal(event.currentTarget.id, scRef);
  };

  const onViewLog = (event) => {
    view.showViewLogModal(event.currentTarget.id, scRef);
  };

  onDestroy(() => {
    saveOrUpdateSub && saveOrUpdateSub.unsubscribe();
  });
</script>

<!--Invisible Element-->
<SC bind:this={scRef} {view} {menuPath} />
<!--//Invisible Element-->

<section class="view-content-controller" style="display: flex; justify-content: space-between; flex-wrap: nowrap">
  <div style="width: 20%; display: flex; flex-wrap: nowrap">
    <Button btnType={ButtonType.back} on:click={onBack} disabled={false} />

    {#if view.isRendered(ButtonId.edit, $isReadOnlyMode$ && $isUpdateMode$)}
      <Button btnType={ButtonType.edit} on:click={onEdit} disabled={view.isDisabled(ButtonId.edit)} />
    {/if}
  </div>

  <div style="width: 40%; white-space: nowrap; text-align: center">
    {#if view.isRendered(ButtonId.update, !$isReadOnlyMode$ && $isUpdateMode$)}
      <Button
        action={useSaveOrUpdateAction}
        btnType={ButtonType.update}
        disabled={view.isDisabled(ButtonId.update)}
        running={$saveRunning$} />
    {/if}
  </div>

  <div style="width: 40%; white-space: nowrap; text-align: right">
    {#if view.isRendered(ButtonId.config)}
      <Button btnType={ButtonType.config} on:click={onViewConfig} disabled={view.isDisabled(ButtonId.config)} />
    {/if}

    {#if view.isRendered(ButtonId.viewLog)}
      <Button btnType={ButtonType.viewLog} on:click={onViewLog} disabled={view.isDisabled(ButtonId.viewLog)} />
    {/if}
  </div>
</section>

<!--Main content-->
<section class="view-content-main">
  <div class="row" style="grid-column-gap:5px">
    {#each orgMenuList as orgMenu, index}
      <div class="col-xs-24 col-md-12 col-lg-8 mx-xs-0 px-xs-0 mb-xs-1 mr-md-0">
        <Item
          {role}
          {orgMenu}
          roleDetail={store.roleDetails[index]}
          roleControlDetails={store.roleControlDetails[index]} />
      </div>
    {/each}
  </div>
</section>
