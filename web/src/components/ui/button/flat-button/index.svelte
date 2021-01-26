<script>
  import { createEventDispatcher, onMount } from 'svelte';
  import { T } from 'src/lib/locale';
  import { StringUtil } from 'src/lib/string-util';
  import { ButtonType, ButtonId } from '../types';
  import DropdownItem from 'src/components/ui/dropdown-item/index.svelte';
  import { Dropdown } from 'src/lib/dropdown';
  import { Browser } from 'src/lib//browser';
  import { debounceTime } from 'src/lib/rx';

  export let id = undefined;
  export let type = 'button';
  export let text = '';
  export let title = '';
  export let btnType = ButtonType.custom;
  export let icon = '';
  export let className = 'btn-flat';
  export let disabled = false;
  export let running = false;
  export let action = undefined;
  export let showIcon = true;
  export let showText = true;
  export let dropdownList = [];
  export let uppercase = true;

  // export let dropdownList: ButtonDropdown[] = [
  //   { id: 'ITEM1', name: 'Demo Item1', useFontIcon: true, fontIcon: '<i class="fab fa-skyatlas"></i>' },
  //   { id: 'ITEM2', name: 'Demo Item2', useFontIcon: true, fontIcon: '<i class="fa fa-adjust"></i>' },
  //   { id: 'ITEM3', name: 'Demo Item3', useFontIcon: true, fontIcon: '<i class="fa fa-allergies"></i>' },
  // ];

  let IconComponent = undefined;
  const BUTTON_MIN_WITH = 120;

  const dispatch = createEventDispatcher();
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
    switch (btnType) {
      case ButtonType.reset:
        preset(undefined, 'RESET', '<i class="fa fa-redo-alt"></i>', 'btn-flat');
        break;
      case ButtonType.addNew:
        preset(ButtonId.addNew, 'ADD_NEW', 'add-new24x24', 'btn-flat');
        break;
      case ButtonType.save:
        preset(ButtonId.save, 'SAVE', 'save24x24', 'btn-flat');
        break;
      case ButtonType.delete:
        preset(ButtonId.delete, 'DELETE', 'delete24x24', 'btn-flat');
        break;
      case ButtonType.edit:
        preset(ButtonId.edit, 'EDIT', 'edit24x24', 'btn-flat');
        break;
      case ButtonType.update:
        preset(ButtonId.update, 'UPDATE', 'update24x24', 'btn-flat');
        break;
      case ButtonType.config:
        preset(ButtonId.config, 'CONFIG', 'config24x24', 'btn-flat');
        break;
      case ButtonType.viewLog:
        preset(ButtonId.viewLog, 'VIEW_LOG', '<i class="fas fa-book-medical"></i>', 'btn-flat');
        break;
      case ButtonType.trashRestore:
        preset(ButtonId.trashRestore, 'TRASH_RESTORE', 'trash-restore', 'btn-flat');
        break;
      case ButtonType.closeModal:
        preset(undefined, undefined, '<i class="fa fa-times"></i>', 'btn-flat');
        break;
      case ButtonType.okModal:
        preset(undefined, 'OK', '<i style="color:#20b04b;" class="fa fa-check"></i>', 'btn-success');
        break;
      case ButtonType.cancelModal:
        preset(undefined, 'CANCEL', '<i style="color:red;" class="fa fa-times"></i>', 'btn-danger');
        break;
      case ButtonType.apply:
        preset(undefined, 'APPLY', '<i class="fa fa-check"></i>', 'btn-flat');
        break;
      case ButtonType.selectAll:
        preset(undefined, undefined, '<i class="fa fa-check-double"></i>', 'btn-small-info');
        break;
      case ButtonType.unSelectAll:
        preset(undefined, undefined, '<i class="fa fa-minus-square"></i>', 'btn-small-success');
        break;
      case ButtonType.toggleSelection:
        preset(undefined, undefined, '<i class="fa fa-toggle-on"></i>', 'btn-small-primary');
        break;
      case ButtonType.submit:
        preset(ButtonId.submit, 'SUBMIT', 'submit24x24', 'btn-flat');
        break;
      case ButtonType.cancelSubmit:
        preset(ButtonId.cancelSubmit, 'CANCEL_SUBMIT', 'cancel-submit24x24', 'btn-flat');
        break;
      case ButtonType.approve:
        preset(ButtonId.approve, 'APPROVE', '<i class="fa fa-check"></i>', 'btn-flat');
        break;
      case ButtonType.cancelApprove:
        preset(ButtonId.cancelApprove, 'CANCEL_APPROVE', '', 'btn-flat');
        break;
      case ButtonType.assign:
        preset(ButtonId.assign, 'ASSIGN', 'assign24x24', 'btn-flat');
        break;
      case ButtonType.unAssign:
        preset(ButtonId.unAssign, 'UN_ASSIGN', 'un-assign24x24', 'btn-flat');
        break;

      case ButtonType.hold:
        preset(ButtonId.hold, 'HOLD', 'hold24x24', 'btn-flat');
        break;
      case ButtonType.unHold:
        preset(ButtonId.unHold, 'UN_HOLD', 'un-hold24x24', 'btn-flat');
        break;

      case ButtonType.dashboard:
        preset(ButtonId.dashboard, 'DASHBOARD', 'dashboard24x24', 'btn-flat');
        break;

      case ButtonType.complete:
        preset(ButtonId.complete, 'COMPLETE', 'complete', 'btn-flat');
        break;

      case ButtonType.unComplete:
        preset(ButtonId.unComplete, 'UN_COMPLETE', 'un-complete', 'btn-flat');
        break;

      case ButtonType.back:
        preset(undefined, 'BACK', '<i class="fa fa-arrow-left"></i>', 'btn-flat');
        break;
      default:
    }

    if (icon && !icon.includes('<')) {
      import(`src/icons/${icon}.svelte`).then((res) => {
        IconComponent = res.default;
      });
    }
  }

  const useAction = (component, param) => {
    if (action) {
      action.register(component, param);
    }
  };

  const onClickItem = (item) => {
    dispatch('itemClick', item);
    Dropdown.hide(`dropdown${id}`);
  };

  const onMouseover = () => {
    Dropdown.show(`dropdown${id}`);
  };

  const onMouseout = () => {
    Dropdown.hide(`dropdown${id}`);
  };

  const showTextOrHide = (containerWidth, childrenCount) => {
    if (btnRef && childrenCount > 0 && containerWidth / childrenCount >= BUTTON_MIN_WITH) {
      showText = true;
      btnRef.style.minWidth = `${BUTTON_MIN_WITH}px`;
    } else if (btnRef) {
      showText = false;
      btnRef.style.minWidth = '50px';
    }
  };

  const onResizeContainer = (e) => {
    const container = e[0].target;
    const containerWidth = window['$'](container).width();
    const childrenCount = container.childElementCount;

    showTextOrHide(containerWidth, childrenCount);
  };

  onMount(() => {
    if (window.isSmartPhone) {
      btnRef.style.minWidth = '50px';
    } else {
      btnRef.style.minWidth = `${BUTTON_MIN_WITH}px`;
    }

    let resizeObserver;

    if (Browser.getBrowser() !== 'Safari') {
      resizeObserver = new ResizeObserver(debounceTime(100, onResizeContainer));
      resizeObserver && resizeObserver.observe(btnRef.parentElement);
    }

    return () => {
      resizeObserver && resizeObserver.unobserve(btnRef.parentElement);
    };
  });
</script>

<button
  title={title ? title : text}
  use:useAction
  bind:this={btnRef}
  {id}
  {type}
  class="{className}
  {uppercase ? 'uppercase' : ''}
  {disabled ? 'disabled' : ''}"
  {disabled}
  on:click|stopPropagation>
  {#if running}
    <i class="fa fa-spinner fa-spin" />
  {:else if showIcon}
    {#if icon && icon.includes('<')}
      {@html icon}
    {:else}
      <svelte:component this={IconComponent} className={disabled ? 'svg-disabled' : ''} />
    {/if}
  {/if}
  {#if showText && !window.isSmartPhone}
    &nbsp; &nbsp;
    {@html text}
  {/if}
  {#if dropdownList && dropdownList.length > 0}
    <i on:mouseover={onMouseover} on:mouseout={onMouseout} class="dropdown-mark-icon fa fa-angle-down">
      <div id={`dropdown${id}`} class="dropdown-content">
        {#each dropdownList as item}
          <DropdownItem
            on:click={(e) => onClickItem(item)}
            useFontIcon={item.useFontIcon}
            fontIcon={item.fontIcon}
            iconData={item.iconData}
            text={item.name} />
        {/each}
      </div>
    </i>
  {/if}
</button>
