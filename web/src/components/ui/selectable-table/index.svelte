<script>
  import './selectable_table.js';
  import { tick, createEventDispatcher } from 'svelte';
  import { onMount } from 'svelte';
  import { SettingsStore } from 'src/store/settings';
  import { T } from 'src/lib/locale';
  import { genUUID } from 'src/lib/random';
  import { SObject } from 'src/lib/sobject';
  import { StringUtil } from 'src/lib/string-util';

  const dispatch = createEventDispatcher();

  export let id = genUUID();
  export let showHeader = true;
  export let columns;
  export let data;
  export let showRowNumber = true;
  export let startRowCount = 1;
  export let menuPath = undefined;
  export let saveState = true;
  export let className = undefined;
  export let selectedId = undefined;

  let startRow = null;
  let selectedRows = [];
  let tableRef;
  let filteredData = data;

  onMount(() => {
    if (saveState && menuPath) {
      loadSettings();
    }
  });

  const onSelectedRow = () => {
    // @ts-ignore
    let selectedRowsData = selectedRows.map((index) => filteredData[index]);

    dispatch('selection', selectedRowsData);
  };

  const getTableId = () => {
    // const jId: any = window['$']('#' + id);
    const jId = window['$'](tableRef);
    return jId;
  };

  const getFirstRowEle = () => {
    return document.querySelector(`#${id} tbody tr :first-child`);
  };
  const applyTable = () => {
    // selectedRows = [];

    getTableId().SelectableTable(
      {
        sort: true,
      },
      function(obj) {
        selectedRows = obj.rows;
        onSelectedRow();

        // register key for navigation
        startRow = document.querySelector(`#row_${obj.rows[0]}_Id :first-child`);
        if (startRow) {
          startRow.focus();
        }
        document.onkeydown = (e) => {
          checkKey(e);
        };
      },
    );
  };

  const selectAll = () => {
    getTableId().selectAll(true, function(obj) {
      selectedRows = obj.rows;
      onSelectedRow();
    });
  };

  export const unSelectAll = () => {
    getTableId().selectAll(false, function(obj) {
      selectedRows = obj.rows;
      onSelectedRow();
    });
  };

  const toggleSelection = () => {
    getTableId().toggleSelection(function(obj) {
      selectedRows = obj.rows;
      onSelectedRow();
    });
  };

  const filter = (textSearch) => {
    if (StringUtil.isEmpty(textSearch)) {
      filteredData = data;
    } else {
      const _data = SObject.clone(data);

      filteredData = _data
        .map((it) => {
          for (let field in it) {
            if (!isHiddenColumn(field) && field !== 'id' && typeof it[field] === 'string') {
              const marked = StringUtil.markStringSearch(it[field], textSearch, true);
              if (marked !== it[field]) {
                it[field] = marked;
                it.found = true;
              }
            }
          }
          return it;
        })
        .filter((it) => it.found);
    }

    // refresh table
    tick().then(() => {
      applyTable();
    });
  };

  const isHiddenColumn = (field) => {
    return columns.filter((it) => it.type === 'hidden' && it.name === field).length > 0;
  };

  const findRowById = (id) => {
    for (let i = 0; i < filteredData.length; i++) {
      if (id && filteredData[i].id && id.toString() === filteredData[i].id.toString()) {
        return i;
      }
    }

    return -1;
  };

  export const selectRowById = (id) => {
    const row = findRowById(id);
    if (row >= 0) {
      getTableId().selectRow(row, function(obj) {
        selectedRows = obj.rows;
        onSelectedRow();
      });
    }
  };

  export const highlightRowById = (id) => {
    const row = findRowById(id);
    if (row >= 0) {
      getTableId().selectRow(row, function(obj) {
        selectedRows = obj.rows;
      });
    }
  };

  export const getSelectedData = () => {
    const result = selectedRows.map((index) => filteredData[index]);
    return result;
  };

  export const getSelectedRowCount = () => {
    return selectedRows.length;
  };

  function dotheneedful(sibling, row) {
    if (sibling != null) {
      sibling.focus();
      // let [, row] = sibling.id.split('_');
      // row = Number(row);
      getTableId().selectRow(row, function(obj) {
        selectedRows = obj.rows;
        onSelectedRow();
      });
      startRow = sibling;
    }
  }

  function checkKey(e) {
    e = e || window.event;
    if (e.code == 'ArrowUp') {
      let idx = startRow.cellIndex;

      let nextrow = startRow.parentElement && startRow.parentElement.previousElementSibling;
      if (nextrow != null) {
        let sibling = nextrow.cells[idx];
        let row = Number(sibling.id.split('_')[1]);
        if (row >= 0) {
          dotheneedful(sibling, row);
          // startingY += 200;
          // window.scrollTo(0, startingY);
        }
      }
    } else if (e.code == 'ArrowDown') {
      let idx = startRow.cellIndex;
      let nextrow = startRow.parentElement && startRow.parentElement.nextElementSibling;
      if (nextrow != null) {
        let sibling = nextrow.cells[idx];
        let row = Number(sibling.id.split('_')[1]);
        if (row < filteredData.length) {
          dotheneedful(sibling, row);
          // startingY += 200;
          // window.scrollTo(0, startingY);
        }
      }
    }
    dispatch('keyup', { event: e, data: getSelectedData() });
  }

  export const focus = () => {
    // register key for navigation
    startRow = getFirstRowEle();
    startRow.focus();
    document.onkeydown = (e) => {
      checkKey(e);
    };

    getTableId().selectRow(0, function(obj) {
      selectedRows = obj.rows;
      onSelectedRow();
    });
  };

  const onClick = (event) => {
    dispatch('click', { event: event, data: getSelectedData() });
  };

  export const selectRowByIndex = (rowIndex) => {
    getTableId().selectRow(rowIndex, function(obj) {
      selectedRows = obj.rows;
      onSelectedRow();
    });
  };

  $: if (data) {
    filteredData = data;
    tick().then(() => {
      applyTable();
    });
  }

  $: {
    if (selectedId) {
      setTimeout(() => {
        selectRowById(selectedId);
      }, 500);
    }
  }

  const saveSettings = () => {
    const headerEle = window['$'](`#${id} thead tr th`);

    const keys = [];
    const values = [];

    headerEle &&
      headerEle.each(function(col) {
        keys.push(`col${col}`);
        values.push(`${window['$'](this).width()}`);
      });

    SettingsStore.saveUserSettings({
      menuPath,
      elementId: id,
      keys,
      values,
    });
  };

  const loadSettings = () => {
    const headerEle = window['$'](`#${id} thead tr th`);

    SettingsStore.getUserSettings({ element: id, menuPath }).then((res) => {
      if (res.data && res.data.length > 0) {
        headerEle.each(function(col) {
          const filter = res.data.filter((it) => it.key === `col${col}`);
          if (filter && filter.length > 0) {
            window['$'](this).width(+filter[0].value);
          }
        });
      } else {
        headerEle.each(function(col) {
          if (showRowNumber) {
            if (col === 0) {
              window['$'](this).width('30px');
            } else if (columns[col - 1].width) {
              window['$'](this).width(columns[col - 1].width);
            }
          } else {
            if (columns[col].width && col < columns.length - 1) {
              window['$'](this).width(columns[col].width);
            }
          }
        });
      }
    });
  };

  const onMouseUpHeader = (event) => {
    if (saveState && menuPath) {
      saveSettings();
    }
  };
</script>

<div style="height: 100%;" id="abcd">
  <slot />

  <span>
    <slot name="header" {selectAll} {unSelectAll} {toggleSelection} {filter} />
  </span>
  <div class="left-content-main-table">
    <div style="height: 100%; overflow: auto;">
      <table bind:this={tableRef} on:click|stopPropagation={onClick} {id} class="table {className}">
        {#if showHeader}
          <thead>
            <tr on:mouseup={onMouseUpHeader}>
              {#if showRowNumber}
                <th title={T('SYS.LABEL.ROW_NUMBER')} class="freeze">#</th>
              {/if}
              {#each columns as col, index}
                {#if col.type !== 'hidden'}
                  <th title={col.title}>
                    {@html col.title}
                  </th>
                {/if}
              {/each}
            </tr>
          </thead>
        {/if}
        <tbody>
          {#each filteredData as row, rowIndex}
            <tr id={'row_' + rowIndex + '_Id'}>
              {#if showRowNumber}
                <th id={`cell_${rowIndex}_${0}_${id}`} class="freeze row-number">{startRowCount + rowIndex}</th>
              {/if}
              {#each columns as col, colIndex}
                {#if col.type !== 'hidden'}
                  <td title={row[col.name]} id={`cell_${rowIndex}_${colIndex}_${id}`}>
                    {@html row[col.name] ? row[col.name] : ''}
                  </td>
                {/if}
              {/each}
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
</div>
