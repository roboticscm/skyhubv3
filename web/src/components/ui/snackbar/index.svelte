<script>
  import { StringUtil } from 'src/lib/string-util';
  import { T } from 'src/lib/locale';
  import { App } from 'src/lib/constants';

  let snackbarRef;
  let msg;

  export const show = (_msg) => {
    msg = _msg;
    snackbarRef.classList.add('show-snackbar');
    setTimeout(() => {
      snackbarRef && snackbarRef.classList.remove('show-snackbar');
    }, App.SNACKBAR_TIMEOUT);
  };

  export const showSaveSuccess = (extraMsg = '') => {
    show(T('SYS.MSG.SAVE_SUCCESS') + (StringUtil.isEmpty(extraMsg) ? '' : '. ' + extraMsg));
  };

  export const showDeleteSuccess = (extraMsg = '') => {
    show(T('SYS.MSG.DELETE_SUCCESS') + (StringUtil.isEmpty(extraMsg) ? '' : '. ' + extraMsg));
  };

  export const showUpdateSuccess = (extraMsg = '') => {
    show(T('SYS.MSG.UPDATE_SUCCESS') + (StringUtil.isEmpty(extraMsg) ? '' : '. ' + extraMsg));
  };

  export const showUnknownError = (extraMsg = '') => {
    show(T('SYS.MSG.UNKNOWN_ERROR') + (StringUtil.isEmpty(extraMsg) ? '' : '. ' + extraMsg));
  };

  export const showTrashEmpty = (extraMsg = '') => {
    show(T('SYS.MSG.TRASH_EMPTY') + (StringUtil.isEmpty(extraMsg) ? '' : '. ' + extraMsg));
  };

  export const showTrashRestoreSuccess = (extraMsg = '') => {
    show(T('SYS.MSG.TRASH_RESTORE_SUCCESS') + (StringUtil.isEmpty(extraMsg) ? '' : '. ' + extraMsg));
  };

  export const showNoDataChange = () => {
    show(T('SYS.MSG.NO_DATA_CHANGE'));
  };
</script>

<div class="snackbar" bind:this={snackbarRef}>{msg}</div>
