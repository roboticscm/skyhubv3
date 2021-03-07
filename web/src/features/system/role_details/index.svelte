<script>
  import { onMount, tick } from 'svelte';
  import { take } from 'rxjs/operators';
  import { BaseView } from 'src/view/base';
  import { ButtonType, ButtonId } from 'src/components/ui/button/types';
  import Button from 'src/components/ui/button/flat-button';
  import ProgressBar from 'src/components/ui/progress-bar';
  import { Store } from './store';
  import { RoleParam } from './types';
  import { App } from 'src/lib/constants';
  import ViewWrapperModal from 'src/components/ui/modal/view-wrapper';
  import TreeView from 'src/components/ui/tree-view';
  import Form from 'src/lib/grpc-form/form';
  import RoleControlList from './components/role-control-list.svelte';
  import { BehaviorSubject } from 'rxjs';
  import { validation } from './validation';
  import Error from 'src/components/ui/error';
  import { SObject } from 'src/lib/sobject';
  import SC from 'src/components/set-common';
  // Props
  export let showTitle = true;
  export let menuPath;
  export let fullControl;
  export let roleControls;
  export let callFrom = 'Self';
  export let showWorkList = false;
  export let selectedId;
  export let searchFields;

  selectedId;
  searchFields;
  showTitle;
  callFrom;
  showWorkList;

  let viewWrapperModalRef,
    modalContentViewRef,
    modalMenuPath,
    orgRoleTreeRef,
    filterOrgTreeRef,
    orgMenuTreeRef,
    scRef,
    next$ = new BehaviorSubject(undefined);

  let nexting = false,
    loadingFilterOrg = false,
    loadingOrgMenu = false;
  // Init view
  const view = new BaseView(menuPath);
  view.fullControl = fullControl;
  view.roleControls = roleControls;
  export const getView = () => view;

  const { ModalContentView$, modalFullControl$, modalRoleControls$, isReadOnlyMode$, copying$ } = view;

  view.loading$.next(true);

  const store = new Store(view);
  store.findOrgRoleTree();
  const { roles$, filterOrg$, orgMenu$ } = store;

  const resetForm = () => {
    return new Form(new RoleParam());
  };
  let form = resetForm();

  $: if ($next$ === false && form && form.role) {
    tick().then(() => {
      orgRoleTreeRef && orgRoleTreeRef.selectNodeById('role' + form.role.id, false);
    });
  }
  // ================= SUBSCRIPTION ========================
  const subscription = () => {
    store.completeLoading$.pipe(take(1)).subscribe((_) => {
      view.loading$.next(false);
    });
  };
  // ================= //SUBSCRIPTION ========================

  // ================= HOOK ========================
  onMount(() => {
    subscription();
  });
  // ================= //HOOK ========================

  const onNext = async () => {
    if (validate()) {
      nexting = true;
      store.roleDetails = [];
      store.roleControlDetails = [];
      for (let i = 0; i < form.checkedRoleOrgMenu.length; i++) {
        let rd;
        try {
          rd = await store.getRoleDetail(
            form.role.id,
            form.checkedRoleOrgMenu[i].parentId,
            form.checkedRoleOrgMenu[i].menuId,
          );
        } catch (e) {
          nexting = false;
          log.error(e.message);
          scRef.snackbarRef().showUnknownError(e.message);
          return;
        }

        if (rd.id !== '0') {
          store.roleDetails.push({ ...rd, found: true });
        } else {
          store.roleDetails.push({ ...rd, found: false, dataLevel: 10000 });
        }
        try {
          const rcd = await store.findRoleControlDetail(rd.id || 0, form.checkedRoleOrgMenu[i].menuId);
          store.roleControlDetails.push(rcd.toObject().dataList);
        } catch (e) {
          nexting = false;
          log.error(e.message);
          scRef.snackbarRef().showUnknownError(e.message);
          return;
        }
      }

      store.roleDetails = [...store.roleDetails];
      store.roleControlDetails = [...store.roleControlDetails];
      store.beforeRoleDetails = SObject.clone(store.roleDetails);
      store.beforeRoleControlDetails = SObject.clone(store.roleControlDetails);
      //for compare object
      store.beforeRoleControlDetails.map((its) =>
        its.map((it) => {
          if (!it.found) {
            it.found = true;
          }
          return it;
        }),
      );

      store.beforeRoleDetails.map((it) => {
        if (!it.found) {
          it.found = true;
        }
        return it;
      });

      next$.next(true);
      nexting = false;
    }
  };

  const onOpenModal = (menuPath) => {
    modalMenuPath = menuPath;
    view.loadModalComponent(menuPath).then((res) => {
      viewWrapperModalRef.show().then((res) => {
        console.log(res);
      });
    });
  };

  const showModalCallback = (event) => {
    console.log(event.detail);
    // if (modalMenuPath === 'task/project') {
    //   form.projectId = event.detail;
    // } else if (modalMenuPath === 'task/priority') {
    //   form.priorityId = event.detail;
    // } else if (modalMenuPath === 'task/task-verification') {
    //   form.evaluateVerificationId = event.detail;
    // } else if (modalMenuPath === 'task/task-qualification') {
    //   form.evaluateQualificationId = event.detail;
    // } else if (modalMenuPath === 'task/status') {
    //   form.evaluateStatusId = event.detail;
    // }
  };

  const onClickOrgRoleTree = (event) => {
    form.errors.clear('role');
    form.errors.errors = { ...form.errors.errors };

    const treeNode = event.detail.treeNode;

    filterOrg$.next([]);
    store.orgMenu$.next([]);
    form.role = undefined;
    form.checkedRoleOrgMenu = [];

    if (treeNode.isParent || !`${treeNode.id}`.startsWith('role')) {
      return;
    }
    const orgId = extractOrgId(treeNode);
    const roleId = extractRoleId(treeNode);

    form.role = {
      id: roleId,
      name: treeNode.name,
    };

    loadingFilterOrg = true;
    store.findOrgTree(orgId).then(() => (loadingFilterOrg = false));
  };

  const extractRoleId = (node) => {
    if (node && node.id && node.id.includes('role')) {
      return node.id.replace('role', '');
    } else {
      return null;
    }
  };
  const extractOrgId = (node) => {
    if (node && node.pId && node.pId.includes('org')) {
      return node.pId.replace('org', '');
    } else {
      return null;
    }
  };

  const onCheckFilterOrgTree = (event) => {
    form.errors.clear('filterOrgIds');
    form.errors.errors = { ...form.errors.errors };

    form.filterOrgIds = filterOrgTreeRef.getCheckedLeafIds(true);
    filterOrg$.value.map((it) => {
      it.checked = form.filterOrgIds.includes(it.id);
      return it;
    });

    store.orgMenu$.next([]);
    form.checkedRoleOrgMenu = [];
    if (form.filterOrgIds.length > 0) {
      loadingOrgMenu = true;
      store.findOrgMenuTree(form.role.id, form.filterOrgIds.join(',')).then(() => (loadingOrgMenu = false));
    }
  };

  const onCheckOrgMenuTree = (event) => {
    form.errors.clear('checkedRoleOrgMenu');
    form.errors.errors = { ...form.errors.errors };

    form.checkedRoleOrgMenu = orgMenuTreeRef
      .getCheckedLeafNodes(true)
      .filter((node) => node.id.startsWith('menu'))
      .map((node) => {
        const obj = {};
        obj.menuId = node.id.replace('menu', '');
        obj.menuName = node.name;

        const parentNode = node.getParentNode();
        if (parentNode) {
          obj.parentId = parentNode.id.replace('org', '');
          obj.parentName = parentNode.name;

          const grandParentNode = parentNode.getParentNode();
          if (grandParentNode) {
            obj.grandParentId = grandParentNode.id.replace('org', '');
            obj.grandParentName = grandParentNode.name;

            const grandParentNode2 = grandParentNode.getParentNode();
            if (grandParentNode2) {
              obj.grandParentId2 = grandParentNode2.id.replace('org', '');
              obj.grandParentName2 = grandParentNode2.name;
            }
          }
        }

        return obj;
      });

    orgMenu$.value.map((it) => {
      it.checked = form.checkedRoleOrgMenu.map((menu) => 'menu' + menu.menuId).includes(it.id);
      return it;
    });
  };

  const validate = () => {
    preprocessData();
    // client validation
    form.errors.errors = form.recordErrors(validation(form));

    if (form.errors.any()) {
      return false;
    }

    return true;
  };

  const onCopy = () => {};

  // ============================== HELPER ==========================
  const preprocessData = () => {};
  // ============================== // HELPER ==========================
</script>

<!--Invisible Element-->
<SC bind:this={scRef} {view} {menuPath} />
<!--//Invisible Element-->
<ViewWrapperModal
  menuInfo={modalContentViewRef && modalContentViewRef.getMenuInfo$()}
  title={modalContentViewRef && modalContentViewRef.getViewTitle()}
  defaultWidth={600}
  defaultHeight={400}
  bind:this={viewWrapperModalRef}
  {menuPath}
  id={'modalWrapper' + view.getViewName() + 'ModalId'}>
  <svelte:component
    this={$ModalContentView$}
    showWorkList={false}
    bind:this={modalContentViewRef}
    showTitle={false}
    on:callback={showModalCallback}
    callFrom={menuPath}
    menuPath={modalMenuPath}
    fullControl={$modalFullControl$}
    roleControls={$modalRoleControls$} />
</ViewWrapperModal>

<ProgressBar loading$={view.loading$} />
<svelte:head>
  <title>{`${App.NAME} - ${view.getViewTitle()}`}</title>
</svelte:head>
<section class="view-container">
  {#if !$next$}
    <!--Form controller-->
    <section class="view-content-controller" style="display: flex; justify-content: space-between; flex-wrap: nowrap">
      <div style="width: 70%; display: flex; flex-wrap: nowrap">
        {#if view.isRendered(ButtonId.copy)}
          <Button
            running={$copying$}
            btnType={ButtonType.copy}
            on:click={onCopy}
            disabled={view.isDisabled(ButtonId.copy)} />
        {/if}
      </div>

      <div style="width: 30%; white-space: nowrap; text-align: right">
        <Button running={nexting} btnType={ButtonType.next} on:click={onNext} disabled={form.errors.any()} />
      </div>
    </section>

    <section class="view-content-main">
      <form class="form">
        <div class="row">
          <div class="col-md-24 col-lg-8 default-border">
            <TreeView
              on:click={onClickOrgRoleTree}
              bind:this={orgRoleTreeRef}
              id={'orgRoleTree' + view.getViewName() + 'Id'}
              data={$roles$}
              disabled={$isReadOnlyMode$}>
              <div slot="label" class="label">{'SYS.LABEL.ROLE'.t()}:</div>
            </TreeView>
            <Error {form} field="role" />
          </div>
          <div class="col-md-24 col-lg-8 default-border {loadingFilterOrg ? 'center-box' : ''}">
            {#if !loadingFilterOrg}
              <TreeView
                isCheckableNode={true}
                on:check={onCheckFilterOrgTree}
                bind:this={filterOrgTreeRef}
                id={'filterOrgTree' + view.getViewName() + 'Id'}
                data={$filterOrg$}
                disabled={$isReadOnlyMode$}>
                <div slot="label" class="label">{'SYS.LABEL.FILTER_ORG'.t()}:</div>
              </TreeView>
              <Error {form} field="filterOrgIds" />
            {:else}
              {@html App.PROGRESS_BAR}
            {/if}
          </div>
          <div class="col-md-24 col-lg-8 default-border {loadingOrgMenu ? 'center-box' : ''}">
            {#if !loadingOrgMenu}
              <TreeView
                isCheckableNode={true}
                on:check={onCheckOrgMenuTree}
                bind:this={orgMenuTreeRef}
                id={'orgMenuTree' + view.getViewName() + 'Id'}
                data={$orgMenu$}
                disabled={$isReadOnlyMode$}>
                <div slot="label" class="label">{'SYS.LABEL.MENU'.t()}:</div>
              </TreeView>

              <Error {form} field="checkedRoleOrgMenu" />
            {:else}
              {@html App.PROGRESS_BAR}
            {/if}
          </div>
          <div class="col-md-24 col-lg-8">
            <input type="button" on:click={() => onOpenModal('system/role')} value="Test Show Dialog" />
          </div>
        </div>
      </form>
    </section>
  {:else}
    <RoleControlList {view} {menuPath} {store} {next$} role={form.role} orgMenuList={form.checkedRoleOrgMenu} />
  {/if}
</section>
