<script>
  import { onMount, createEventDispatcher } from 'svelte';
  import { SObject } from 'src/lib/sobject';
  import { StringUtil } from 'src/lib/string-util';
  import { App } from 'src/lib/constants';
  import { BehaviorSubject, Observable } from 'rxjs';
  import { map, switchMap, tap, filter, distinctUntilChanged } from 'rxjs/operators';
  import { fromEvents } from 'src/lib/rx';
  import SelectableTable from 'src/components/ui/selectable-table/index.svelte';
  import { SettingsStore } from 'src/store/settings';
  import { SearchType } from 'src/components/search-bar/types';
  import { passwordChar } from './helper';
  import { Browser } from 'src/lib/browser';
  import SearchIcon from 'src/icons/search.svelte';
  import { of } from 'rxjs';

  export let columns;
  export let height = '50vh';
  export let id;
  export let saveState = false;
  export let disabled = false;
  export let menuPath;
  export let searchFunc;
  export let className;
  export let type = 'search';
  export let placeholder = '';
  export let container = undefined;
  export let searching$ = new BehaviorSubject(false);
  export let useInternalProgress = true;

  const isLogged$ = of(false);

  let inputWrapperRef;
  let inputRef;
  let inputWidth;
  let tableRef;

  let password = '';
  let memoryPassword = '';

  let dropdownFocused = false;
  let textSearch = '';
  let selectedItem = undefined;
  let markData = [];
  let disableAutocomplete;
  let showBackButton;

  const dispatch = createEventDispatcher();
  const displayChar = passwordChar();
  const isSmartPhone = window.isSmartPhone;

  const isSafari = Browser.getBrowser() === 'Safari';

  $: {
    disableAutocomplete = type === 'password';
    showBackButton = type === 'password';
  }
  const showAutoDropdown = () => {
    if (disableAutocomplete) {
      return;
    }

    dispatch('showPopup', undefined);
    if (!container) {
      inputWidth = window['$'](inputRef).width();
    } else {
      inputWidth = window['$'](container).width();
    }

    document.querySelector(`#dropdown${id}`).style.width = inputWidth + 'px';
    tableRef.unSelectAll();
    document.querySelector(`#${'dropdown' + id}`).classList.add('show-auto-dropdown');
  };

  const hideAutoDropdown = () => {
    dispatch('hidePopup', undefined);
    setTimeout(() => {
      dropdownFocused = false;
    }, 200);

    const ele = document.querySelector(`#${'dropdown' + id}`);
    ele && ele.classList.remove('show-auto-dropdown');
  };

  const didSearch = (data) => {
    if (data && data.length > 0) {
      //highligth text
      const temp = SObject.clone(data);

      if (type !== 'password') {
        markData = temp.map((item) => {
          const markedName = StringUtil.markStringSearch(item.name, textSearch, true);
          item.name = markedName;
          return item;
        });
      } else {
        markData = temp;
      }

      showAutoDropdown();
      useInternalProgress && searching$.next(false);
    } else {
      hideAutoDropdown();
      useInternalProgress && searching$.next(false);
    }
  };

  const preSearch = (event) => {
    if (event.code === 'Escape') {
      hideAutoDropdown();
      return false;
    }

    if (!dropdownFocused && event.code === 'ArrowDown') {
      tableRef.focus();
      dropdownFocused = true;
      return false;
    } else if (event.code === 'ArrowDown') {
      return false;
    }

    if (!isSmartPhone && !dropdownFocused && event.code === 'Enter') {
      if (type === 'password') {
        const pw = getPassword();
        if (!StringUtil.isEmpty(pw)) {
          dispatch('change', {
            id: SearchType.Login,
            name: pw,
          });
        }
      } else if (!$isLogged$) {
        dispatch('change', {
          id: SearchType.Login,
          name: inputRef && inputRef.value,
        });
      } else {
        dispatch('change', {
          id: undefined,
          name: inputRef && inputRef.value,
        });
      }
      hideAutoDropdown();
      return false;
    }

    return true;
  };

  const doSearch = () => {
    const events$ = fromEvents(inputRef, 'keyup', 'click').pipe(
      filter((event) => preSearch(event)),
      map((event) => {
        return {
          type: event.type,
          value: event.target.value,
        };
      }),
    );
    events$
      .pipe(
        distinctUntilChanged((before, after) => {
          return before.value === after.value && after.type !== 'click';
        }),
        tap((event) => {
          if (type !== 'password') {
            textSearch = event.value;
          } else {
            textSearch = getPassword();
          }
          useInternalProgress && searching$.next(true);
        }),
        switchMap((event) => {
          if (type !== 'password') {
            return searchFunc(event.value);
          } else {
            return searchFunc(getPassword());
          }
        }),
      )
      .subscribe({
        next: (res) => {
          didSearch(res.data);
        },
        error: (error) => {
          useInternalProgress && searching$.next(false);
        },
      });
  };

  const hideOnLostFocus = () => {
    if (document.activeElement !== inputRef) {
      if (inputRef && StringUtil.isEmpty(inputRef.value)) {
        selectItem([
          {
            id: '',
            name: '',
          },
        ]);
      }
      hideAutoDropdown();
    }
  };

  export const getSelectedItem = () => {
    if (selectedItem && selectedItem.name && textSearch !== StringUtil.removeMark(selectedItem.name)) {
      return null;
    }
    return selectedItem;
  };

  export const getSelectedId = () => {
    const selectedItem = getSelectedItem();
    return selectedItem ? selectedItem.id : null;
  };

  export const getSelectedName = () => {
    if (textSearch.trim().length === 0) {
      selectedItem = undefined;
    }
    const _selectedItem = getSelectedItem();
    return _selectedItem ? _selectedItem.name : null;
  };

  export const getInputText = () => {
    return textSearch;
  };

  export const loadSettings = () => {
    return new Observable((observer) => {
      SettingsStore.getUserSettings({ elementId: id, menuPath })
        .then((res) => {
          const data = res.data;
          const idFilter = data.filter((it) => it.key === 'autoId');

          let id = null;
          if (idFilter.length > 0) {
            id = idFilter[0].value;
          }

          const nameFilter = data.filter((it) => it.key === 'autoName');
          let name = null;
          if (nameFilter.length > 0) {
            name = nameFilter[0].value;
            textSearch = name;
          }

          selectedItem = {
            id,
            name,
          };

          observer.next(selectedItem);
          observer.complete();
        })
        .catch((error) => observer.error(error));
    });
  };

  onMount(() => {
    doSearch();
    document.addEventListener('click', () => {
      hideOnLostFocus();
    });
    if (inputRef) {
      inputRef.focus();
    }
  });

  const selectItem = (data) => {
    if (data.length >= 0) {
      if (data[0] && data[0].name) {
        if (type !== 'password') {
          textSearch = StringUtil.removeMark(data[0].name);
          inputRef.value = textSearch;
        } else {
          textSearch = getPassword();
        }

        selectedItem = data[0];
        if (saveState) {
          SettingsStore.saveUserSettings({
            menuPath,
            controlId: id,
            keys: ['autoId', 'autoName'],
            values: [data[0].id, textSearch],
          });
        }

        dispatch('change', {
          id: data[0].id,
          name: textSearch,
        });
      }
    }
  };

  const onTableClick = (event) => {
    selectItem(event.detail.data);
    hideAutoDropdown();
  };

  const onTableKeyup = (event) => {
    if (dropdownFocused) {
      if (event.detail.event.code === 'Enter') {
        selectItem(event.detail.data);
        hideAutoDropdown();
      }
    } else {
      if (event.detail.event.code === 'Enter') {
        if (type === 'password') {
          selectItem({
            id: SearchType.Login,
            name: getPassword(),
          });
        } else {
          selectItem({
            id: undefined,
            name: inputRef.value,
          });
        }

        hideAutoDropdown();
      }
    }
  };

  export const focus = () => {
    inputRef.focus();
  };

  export const clear = () => {
    inputRef.value = '';
    memoryPassword = '';
  };

  const onClickBack = () => {
    dispatch('clickBack', undefined);
  };

  const onClickNext = () => {
    dispatch('change', {
      id: SearchType.Login,
      name: getPassword(),
    });
  };

  const onKeyup = (event) => {
    if (type !== 'password') {
      return;
    }

    if (event.key === 'Backspace' || event.key === 'Delete') {
      const start = inputRef.selectionStart;
      const end = inputRef.selectionStart;
      if (start === 0 && end === 0) {
        memoryPassword = '';
      } else {
        memoryPassword = memoryPassword.slice(0, start) + memoryPassword.slice(start + 1, memoryPassword.length);
      }
    }
  };

  const onInput = (event) => {
    if (type !== 'password') {
      return;
    }

    if (event.data) {
      const pos = inputRef.selectionStart;
      memoryPassword = StringUtil.insertAt(memoryPassword, event.data, pos);

      inputRef.value = new Array(inputRef.value.length).fill(displayChar).join('');
    }
  };

  const onChange = () => {
    if (!isSmartPhone) {
      return;
    }

    if (!dropdownFocused) {
      if (type === 'password') {
        dispatch('change', {
          id: SearchType.Login,
          name: getPassword(),
        });
      } else if (!$isLogged$) {
        dispatch('change', {
          id: SearchType.Login,
          name: inputRef.value,
        });
      } else {
        dispatch('change', {
          id: undefined,
          name: inputRef.value,
        });
      }
    }
    hideAutoDropdown();
  };

  export const getPassword = () => {
    return memoryPassword;
  };
</script>

<div class="w-100 auto-dropdown-wrapper" {id} bind:this={inputWrapperRef}>
  {#if isSafari}
    <input
      style="font-size: 1rem"
      on:input={onInput}
      required
      on:keyup={onKeyup}
      on:change={onChange}
      bind:value={password}
      bind:this={inputRef}
      autocomplete="off"
      type="text"
      {placeholder}
      class="input {showBackButton ? 'input-left-indent input-large-spacing hide-search-icon' : 'search-mode'}"
      {disabled} />
  {:else}
    <input
      style="font-size: 1rem"
      on:input={onInput}
      required
      on:keyup={onKeyup}
      on:change={onChange}
      bind:value={password}
      bind:this={inputRef}
      autocomplete="off"
      type="search"
      {placeholder}
      class="input {showBackButton ? 'input-left-indent input-large-spacing hide-search-icon' : 'search-mode'}"
      {disabled} />
  {/if}

  {#if showBackButton}
    <i on:click={onClickBack} class="back-button fa fa-arrow-left" />
    <i on:click={onClickNext} class="next-button fa fa-arrow-right" />
  {/if}
  <!--  <i class="search-icon fa fa-search" />-->
  <div class="search-icon">
    <SearchIcon />
  </div>
  <div class="search-progress">
    {#if $searching$}
      {@html App.PROGRESS_BAR}
    {/if}
  </div>
  <div style={`height: ${height};`} class="auto-dropdown {className}" id={'dropdown' + id}>
    <SelectableTable
      on:click={onTableClick}
      on:keyup={onTableKeyup}
      bind:this={tableRef}
      id={'table' + id}
      data={markData}
      showRowNumber={false}
      {columns}
      {menuPath}
      {saveState}
      showHeader={false} />
  </div>
</div>
