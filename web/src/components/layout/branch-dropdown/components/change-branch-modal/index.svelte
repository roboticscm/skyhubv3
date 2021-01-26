<script>
  import Modal from 'src/components/ui/modal/base/index.svelte';
  import Snackbar from 'src/components/ui/snackbar/index.svelte';
  import TreeView from 'src/components/ui/tree-view/index.svelte';
  import { OrgStore } from 'src/features/system/org/store';
  import { T } from 'src/lib/locale';
  import { ButtonPressed } from 'src/components/ui/button/types';
  import { LoginInfo } from 'src/store/login-info';
  let snackbarRef, modalRef, treeRef;

  export const show = () => {
    treeRef.checkNodeById(LoginInfo.branchId$.value);
    return modalRef.show().then((buttonPress) => {
      if (buttonPress === ButtonPressed.ok) {
        const nodes = treeRef.getCheckedNodes();
        LoginInfo.branchId$.next(nodes[0].id);
        LoginInfo.branchName$.next(nodes[0].name);
        LoginInfo.companyName$.next(treeRef.getNodeById(nodes[0].pId).name);
      }
    });
  };

  const onClickTree = (e) => {
    console.log(e.detail);
  };

  const checkSelectedBranch = () => {
    return new Promise((resolve, reject) => {
      const nodes = treeRef.getCheckedNodes();
      if (nodes && (nodes.length !== 1 || nodes[0].type != 10)) {
        snackbarRef.show(T('SYS.MSG.PLEASE_SELECT_BRANCH'));
        resolve(false);
      } else {
        resolve(true);
      }
    });
  };
</script>

<Snackbar bind:this={snackbarRef} />
<Modal
  beforeOK={checkSelectedBranch}
  contentClass="full-modal-content"
  fontIcon="<i class='fa fa-user-circle'></i>"
  title={T('SYS.LABEL.CHANGE_BRANCH')}
  id="changeBranchModalId"
  menuPath="system/branch/change-branch"
  bind:this={modalRef}>
  <TreeView bind:this={treeRef} data$={OrgStore.branches$} radioType="all" on:click={onClickTree} />
</Modal>
