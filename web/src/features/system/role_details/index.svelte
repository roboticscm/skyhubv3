<script>
  import { onMount } from 'svelte';
  import { take } from 'rxjs/operators';
  import { ViewStore } from 'src/store/view';
  import { ButtonType } from 'src/components/ui/button/types';
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
  fullControl;
  roleControls;
  callFrom;
  showWorkList;

  let viewWrapperModalRef,
    modalContentViewRef,
    modalMenuPath,
    orgRoleTreeRef,
    filterOrgTreeRef,
    orgMenuTreeRef,
    checkedRoleOrgMenu,
    selectedRole,
    next$ = new BehaviorSubject(false);
  // Init view
  const view = new ViewStore(menuPath);
  export const getView = () => view;

  const { ModalContentView$, modalFullControl$, modalRoleControls$, isReadOnlyMode$ } = view;

  view.loading$.next(true);

  const store = new Store(view);
  store.findOrgRoleTree();
  const { roles$, filterOrg$, orgMenu$ } = store;

  const resetForm = () => {
    return new Form(new RoleParam());
  };
  let form = resetForm();

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

  const onNext = () => {
    if (validate()) {
      next$.next(true);
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
    form.errors.clear('roleId');
    form.errors.errors = { ...form.errors.errors };

    const treeNode = event.detail.treeNode;

    if (treeNode.isParent) {
      filterOrg$.next(null);
      form.roleId = undefined;
      return;
    }
    const orgId = extractOrgId(treeNode);
    const roleId = extractRoleId(treeNode);

    selectedRole = {
      id: roleId,
      name: treeNode.name,
    };
    form.roleId = roleId;
    store.findOrgTree(orgId);
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

    const checkOrgIds = filterOrgTreeRef.getCheckedLeafIds(true);
    form.filterOrgIds = checkOrgIds;
    store.findOrgMenuTree(checkOrgIds.join(','));
  };

  const onCheckOrgMenuTree = (event) => {
    form.errors.clear('checkedRoleOrgMenu');
    form.errors.errors = { ...form.errors.errors };

    checkedRoleOrgMenu = orgMenuTreeRef
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
      form.checkedRoleOrgMenu = checkedRoleOrgMenu;
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

  // ============================== HELPER ==========================
  const preprocessData = () => {
    
  };
  // ============================== // HELPER ==========================
</script>

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
      <div style="width: 70%; display: flex; flex-wrap: nowrap" />

      <div style="width: 30%; white-space: nowrap; text-align: right">
        <Button btnType={ButtonType.custom} text={'SYS.BUTTON.NEXT'.t()} on:click={onNext} disabled={form.errors.any()} />
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
            <Error {form} field="roleId" />
          </div>
          <div class="col-md-24 col-lg-8 default-border">
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
          </div>
          <div class="col-md-24 col-lg-8 default-border">
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
          </div>
          <div class="col-md-24 col-lg-8">
            <input type="button" on:click={() => onOpenModal('system/role')} value="Test Show Dialog" />
          </div>
        </div>
      </form>
    </section>
  {:else}
    <RoleControlList {next$} role={selectedRole} orgMenuList={checkedRoleOrgMenu} />
  {/if}
</section>
