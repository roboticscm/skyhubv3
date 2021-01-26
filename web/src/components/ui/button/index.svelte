<script>
  import { T } from 'src/lib//locale';
  import { StringUtil } from 'src/lib/string-util';
  import { ButtonType, ButtonId } from './types';

  export let id = undefined;
  export let type = 'button';
  export let title = '';
  export let text = '';
  export let btnType = ButtonType.custom;
  export let icon = '';
  export let className = '';
  export let disabled = false;
  export let running = false;
  export let action = undefined;
  export let uppercase = true;

  let btnRef;
  export const getTarget = () => {
    return btnRef;
  };

  const preset = (_id, _title, _icon, _className) => {
    if (StringUtil.isEmpty(id) && !StringUtil.isEmpty(_id)) {
      id = _id;
    }
    if (StringUtil.isEmpty(text) && !StringUtil.isEmpty(_title)) {
      text = T(`SYS.BUTTON.${_title}`);
    }
    if (StringUtil.isEmpty(icon) && !StringUtil.isEmpty(_icon)) {
      icon = _icon;
    }

    if (StringUtil.isEmpty(className) && !StringUtil.isEmpty(_className)) {
      className = _className;
    }
  };

  $: {
    switch (+btnType) {
      case ButtonType.Reset:
        preset(undefined, 'Reset', '<i class="fa fa-redo-alt"></i>', 'btn-info');
        break;
      case ButtonType.AddNew:
        preset(ButtonId.AddNew, 'ADD_NEW', '<i class="fa fa-plus"></i>', 'btn-info');
        break;
      case ButtonType.Save:
        preset(ButtonId.Save, 'SAVE', '<i class="fa fa-save"></i>', 'btn-primary');
        break;
      case ButtonType.Delete:
        preset(ButtonId.Delete, 'DELETE', '<i class="fa fa-trash-alt"></i>', 'btn-danger');
        break;
      case ButtonType.Edit:
        preset(ButtonId.Edit, 'EDIT', '<i class="fa fa-edit"></i>', 'btn-success');
        break;
      case ButtonType.Update:
        preset(ButtonId.Update, 'UPDATE', '<i class="fa fa-save"></i>', 'btn-primary');
        break;
      case ButtonType.Config:
        preset(ButtonId.Config, 'CONFIG', '<i class="fa fa-cog"></i>', 'btn-normal');
        break;
      case ButtonType.TrashRestore:
        preset(ButtonId.TrashRestore, 'TRASH_RESTORE', '<i class="fa fa-trash-restore-alt"></i>', 'btn-success');
        break;
      case ButtonType.CloseModal:
        preset(undefined, undefined, '<i class="fa fa-times"></i>', 'btn-small-normal');
        break;
      case ButtonType.OkModal:
        preset(undefined, 'OK', '<i class="fa fa-check"></i>', 'btn-success');
        break;
      case ButtonType.CancelModal:
        preset(undefined, 'CANCEL', '<i class="fa fa-times"></i>', 'btn-danger');
        break;
      case ButtonType.Apply:
        preset(undefined, 'APPLY', '<i class="fa fa-check"></i>', 'btn-success');
        break;
      case ButtonType.SelectAll:
        preset(undefined, undefined, '<i class="fa fa-check-double"></i>', 'btn-small-info');
        break;
      case ButtonType.UnSelectAll:
        preset(undefined, undefined, '<i class="fa fa-minus-square"></i>', 'btn-small-success');
        break;
      case ButtonType.ToggleSelection:
        preset(undefined, undefined, '<i class="fa fa-toggle-on"></i>', 'btn-small-primary');
        break;
      default:
    }
  }

  const useAction = (component, param) => {
    if (action) {
      action.register(component, param);
    }
  };
</script>

<button
  {title}
  use:useAction
  bind:this={btnRef}
  {id}
  {type}
  class="{className}
  {uppercase ? 'uppercase' : ''}"
  {disabled}
  on:click>
  {#if running}
    <i class="fa fa-spinner fa-spin" />
  {:else}
    {@html icon}
  {/if}
  {text}
</button>
