<script>
  import { createEventDispatcher, onMount } from 'svelte';
  import { T } from 'src/lib/locale';
  import { Observable } from 'rxjs';
  import { SettingsStore } from 'src/store/settings';

  export let id;
  export let menuPath;

  export let name = undefined;
  export let disabled = false;
  export let className = '';
  export let placeholder;
  export let checked = undefined;
  export let rightCheck = false;
  export let data = undefined;
  export let data$ = undefined;
  export let saveState = false;
  export let showAllItem = false;
  export let showSelectOneItem = false;
  export let value = undefined;
  export let autoLoad = false;
  export let selectedId = undefined;

  const dispatch = createEventDispatcher();

  let _selectedId = selectedId;

  let inputRef;
  let _data = [];

  export const focus = () => {
    if (inputRef) {
      inputRef.focus();
    }
  };

  const onCheck = () => {
    inputRef && inputRef.focus();
  };

  const onChange = (event) => {
    _selectedId = event.target.value;
    if (saveState) {
      SettingsStore.saveUserSettings({
        menuPath,
        elementId: id,
        keys: ['lastSelected'],
        values: [_selectedId],
      });
    }
    dispatch('change', _selectedId);
  };

  export const getSelectedId = () => {
    if (_selectedId) {
      return _selectedId;
    } else {
      return inputRef && inputRef.value;
    }
  };

  export const getSelectedName = () => {
    let selectedItem = getSelectedItem();
    if (selectedItem) {
      return selectedItem.name;
    } else {
      return null;
    }
  };

  export const getSelectedItem = () => {
    const selectedId = getSelectedId();
    const selectedItem = _data.filter((item) => item.id == selectedId);
    if (selectedItem && selectedItem.length > 0) {
      return selectedItem[0];
    } else {
      return null;
    }
  };

  export const loadSettings = () => {
    return new Observable((observer) => {
      SettingsStore.getUserSettings({ elementId: id, menuPath, key: 'lastSelected' })
        .then((res) => {
          if (res.data.length > 0) {
            if (res.data[0].key === 'lastSelected') {
              _selectedId = res.data[0].value;
              value = res.data[0].value;
            }
          }

          observer.next(res);
          observer.complete();
        })
        .catch((error) => observer.error(error));
    });
  };

  onMount(() => {
    if (autoLoad) {
      loadSettings().subscribe();
    }
  });

  const onClickLabel = () => {
    if (disabled) {
      return;
    }

    dispatch('clickLabel');
  };
  $: {
    if ($data$) {
      _data = $data$;
    } else {
      _data = data;
    }
  }
</script>

<div class="floating-wrapper">
  <select
    on:blur={onChange}
    bind:value
    {name}
    {disabled}
    class="{checked !== undefined ? 'check' : ''}
    {rightCheck ? 'right' : ''}
    {className}"
    bind:this={inputRef}>

    {#if showSelectOneItem}
      <option value={null}>{T('SYS.LABEL.PLEASE_SELECT_ONE')}</option>
    {/if}
    {#if showAllItem}
      <option value={undefined}>{'--- ' + T('SYS.LABEL.ALL') + ' ---'}</option>
    {/if}

    {#if _data && _data.length > 0}
      {#each _data as item}
        <option value={item.id} selected={item.id == _selectedId}>{item.name}</option>
      {/each}
    {:else}
      <option>{T('SYS.LABEL.LOADING')}...</option>
    {/if}

  </select>

  <label
    for={name}
    on:click|stopPropagation={onClickLabel}
    class="floating__label {disabled ? 'disabled' : ''}"
    data-content={placeholder} />
  {#if checked !== undefined}
    <input class={rightCheck ? 'right' : ''} tabindex="-1" bind:checked type="checkbox" on:change={onCheck} />
  {/if}
  <i class="dropdown-icon fa fa-angle-down {rightCheck ? 'right' : ''}" />
</div>
