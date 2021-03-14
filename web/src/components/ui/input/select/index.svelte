<script>
  import { onMount, createEventDispatcher } from 'svelte';
  import { SettingsStore } from 'src/store/settings';
  import { Observable } from 'rxjs';
  import { take } from 'rxjs/operators';

  export let id = undefined;
  export let data;
  export let disabled = false;
  export let saveState = false;
  export let autoLoad = false;
  export let selectedId = undefined;
  export let showAllItem = false;
  export let menuPath = undefined;
  export let showSelectOneItem = false;

  const dispatch = createEventDispatcher();

  let selectRef;
  let _selectedId = selectedId;

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
      return selectRef && selectRef.value;
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
    const selectedItem = data.filter((item) => item.id == selectedId);
    if (selectedItem && selectedItem.length > 0) {
      return selectedItem[0];
    } else {
      return null;
    }
  };

  export const loadSettings = () => {
    return new Observable((observer) => {
      SettingsStore.findUserSettings({ elementId: id, menuPath })
        .then((res) => {
          if (res.length > 0) {
            if (res[0].key === 'lastSelected') {
              _selectedId = res[0].value;
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
      loadSettings()
        .pipe(take(1))
        .subscribe();
    }
  });
</script>

<style lang="scss" scoped>

</style>


<!-- svelte-ignore a11y-no-onchange -->
<select bind:this={selectRef} class="form-control-dropdown full-width" {id} on:change={onChange} {disabled}>
  {#if showSelectOneItem}
    <option disabled selected={!saveState && _selectedId === undefined} value={-1}>
      {'COMMON.MSG.PLEASE_SELECT_ONE'.t()}
    </option>
  {/if}
  {#if showAllItem}
    <option value={undefined}>{'--- ' + 'COMMON.LABEL.ALL'.t() + ' ---'}</option>
  {/if}
  {#each data as item}
    <option value={item.id} selected={item.id == _selectedId}>{item.name}</option>
  {/each}
</select>
