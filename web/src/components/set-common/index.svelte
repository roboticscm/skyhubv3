<script>
  import { T } from 'src/lib/locale';
  import { ModalType } from 'src/components/ui/modal/types';

  import ConfirmModal from 'src/components/ui/modal/base';
  import ConfirmDeleteModal from 'src/components/ui/modal/base';
  import ConfirmPasswordModal from 'src/components/ui/modal/base';
  import ConfirmConflictDataModal from 'src/components/ui/modal/conflict-data-confirm';
  import ConfigModal from 'src/components/ui/modal/view-config';
  import ViewLogModal from 'src/components/ui/modal/view-log';
  import TrashRestoreModal from 'src/components/ui/modal/trash-restore';
  import Snackbar from 'src/components/ui/snackbar';

  // Props
  export let view;
  export let menuPath;

  // external
  let _confirmModalRef;
  let _confirmDeleteModalRef;
  let _confirmPasswordModalRef;
  let _snackbarRef;
  let _configModalRef;
  let _viewLogModalRef;
  let _trashRestoreModalRef;
  let _confirmConflictDataModalRef;

  export const confirmModalRef = () => {
    return _confirmModalRef;
  };

  export const confirmDeleteModalRef = () => {
    return _confirmDeleteModalRef;
  };

  export const confirmPasswordModalRef = () => {
    return _confirmPasswordModalRef;
  };

  export const snackbarRef = () => {
    return _snackbarRef;
  };

  export const configModalRef = () => {
    return _configModalRef;
  };

  export const viewLogModalRef = () => {
    return _viewLogModalRef;
  };

  export const trashRestoreModalRef = () => {
    return _trashRestoreModalRef;
  };

  export const confirmConflictDataModalRef = () => {
    return _confirmConflictDataModalRef;
  };
</script>

<!--Invisible Element-->
<Snackbar bind:this={_snackbarRef} />
<ConfirmConflictDataModal
  {menuPath}
  id={'conflictData' + view.getViewName() + 'Modal'}
  bind:this={_confirmConflictDataModalRef} />
<ConfirmModal modalType={ModalType.Confirm} {menuPath} bind:this={_confirmModalRef} />
<ConfirmDeleteModal
  id="mdConfirmDeleteModal"
  title={T('SYS.LABEL.DELETE')}
  modalType={ModalType.Confirm}
  {menuPath}
  bind:this={_confirmDeleteModalRef} />
<ConfirmPasswordModal modalType={ModalType.ConfirmPassword} {menuPath} bind:this={_confirmPasswordModalRef} />
<ConfigModal
  {menuPath}
  subTitle={view.getViewTitle()}
  id={'configModal' + view.getViewName()}
  bind:this={_configModalRef}
  containerWidth="500px" />
<TrashRestoreModal
  columns={view.trashRestoreColumns}
  {menuPath}
  subTitle={view.getViewTitle()}
  id={'trashRestoreModal' + view.getViewName()}
  bind:this={_trashRestoreModalRef}
  containerWidth="600px" />

<ViewLogModal
  {menuPath}
  subTitle={view.getViewTitle()}
  id={'viewLogModal' + view.getViewName()}
  bind:this={_viewLogModalRef}
  containerWidth="500px" />
<!--//Invisible Element-->
