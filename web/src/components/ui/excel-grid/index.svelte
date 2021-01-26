<script>
  import { onMount, onDestroy, createEventDispatcher } from 'svelte';
  import jexcel from 'jexcel';
  import { errorSection } from 'src/lib/debug';
  import { SettingsStore } from 'src/store/settings';
  import { T } from 'src/lib/locale';
  const dispatch = createEventDispatcher();

  export let id;
  export let fullWidth = true;
  export let columns;
  export let data;
  export let height = '70vh';
  export let gridMergeCells = {};
  export let menuPath;
  export let containerWidth = undefined;
  export let gridNestedHeaders = [];
  export let useInModal = true;
  export let mouseUp = undefined;

  let gridRef;

  let jExcelObj;
  let startTime = Date.now();

  let fireResizeEvent = true;

  const onWindowResize = (event) => {
    // const containerWidth = event.target.innerWidth;
    let now = Date.now();
    if (now - startTime > 100) {
      startTime = now;
    } else {
      return;
    }

    if (!jExcelObj) {
      return;
    }
    recalculateColumnWidth();
    columns.map((col, index) => {
      if (col.type !== 'hidden') {
        jExcelObj.setWidth(index, +col.width);
      }
    });
  };

  onMount(() => {
    if (!useInModal) {
      window.addEventListener('resize', onWindowResize);
    }
  });

  const onChanged = (instance, cell, x, y, value) => {
    dispatch('changed', { instance, cell, x, y, value });
  };

  // TODO: param not test
  const onBeforeChange = (instance, cell, x, y, value) => {
    dispatch('beforeChange', { instance, cell, x, y, value });
  };

  const recalculateColumnWidth = () => {
    const _containerWidth = window['$'](gridRef).width();

    const colIndexWidth = 60;
    if (_containerWidth <= colIndexWidth) {
      return;
    }
    if (fullWidth) {
      const beforeWidthSum = columns
        .map((it) => (it.type === 'hidden' ? 0 : it.width ? +it.width : 0))
        .reduce((w1, w2) => {
          return w1 + w2;
        }, 0);

      const ratio = (_containerWidth - colIndexWidth) / beforeWidthSum;

      columns.map((col) => {
        if (col.type !== 'hidden') {
          col.width = Math.round(ratio * col.width);
        }
        return col;
      });
    }
  };

  const createGrid = (data) => {
    if (!jExcelObj) {
      if (!id) {
        errorSection('Excel Grid', "Maybe you didn't set Id for this Grid");
        return;
      }
      if (!columns || columns.length === 0) {
        return;
      }

      const el = document.getElementById(id);
      if (!el) {
        return;
      }
      recalculateColumnWidth();
      jExcelObj = jexcel(el, {
        data: data,
        // editable: false,
        columns: columns,
        updateTable: onUpdateTable,
        onchange: onChanged,
        onbeforechange: onBeforeChange,
        onbeforedeleterow: onBeforeDeleteRow,
        onselection: onSelection,
        tableOverflow: true,
        tableWidth: '100%',
        tableHeight: height,
        mergeCells: gridMergeCells,
        nestedHeaders: gridNestedHeaders,
        allowInsertRow: true,
        columnDrag: true,
        rowDrag: true,
        // contextMenu: function() {
        //   return false;
        // },
        onresizecolumn: (instance, col, width) => {
          recalculateColumnWidth();
          if (fireResizeEvent) {
            saveSettings(col, columns[col].width);
          }
        },
      });
      // jExcelObj.resetSelection(true);
      loadSettings();
    } else {
      jExcelObj.destroyMerged();
      jExcelObj.setData(data);
      for (let prop in gridMergeCells) {
        jExcelObj.setMerge(prop, gridMergeCells[prop][0], gridMergeCells[prop][1]);
      }
    }
  };

  export const getData = () => {
    return jExcelObj.getJson();
  };

  const saveSettings = (col, width) => {
    SettingsStore.saveUserSettings({
      menuPath,
      elementId: id,
      keys: [`col${col}`],
      values: [width + ''],
    });
  };

  const loadSettings = () => {
    fireResizeEvent = false;
    SettingsStore.getUserSettings({ elementId: id, menuPath })
      .then((res) => {
        const data = res.data;
        if (data) {
          data.map((item) => {
            let column = Number(item.key);
            let value = Number(item.value);
            if (jExcelObj) {
              if (fullWidth) {
                if (columns.length > column) {
                  columns[column].width = value;
                }
              } else {
                jExcelObj.setWidth(column, value);
              }
            }
          });

          if (fullWidth) {
            recalculateColumnWidth();
            columns.map((col, index) => {
              jExcelObj.setWidth(index, col.width);
            });
          }
        }
        fireResizeEvent = true;
      })
      .catch((error) => {
        fireResizeEvent = true;
        console.error(error);
      });
  };

  const destroyGrid = () => {
    const ele = document.getElementById(id);
    if (ele) {
      jexcel.destroy(ele);
      jExcelObj = null;
    }
  };
  onDestroy(() => {
    window.removeEventListener('resize', onWindowResize);
    destroyGrid();
  });

  onMount(() => {
    createGrid(data);
  });

  const onBeforeDeleteRow = (event) => {
    dispatch('beforeDeleteRow', event);
    return true;
  };

  const onUpdateTable = (el, cell, x, y, source, value, id) => {
    dispatch('updateTable', {
      el,
      cell,
      x,
      y,
      source,
      value,
      id,
    });
  };

  const onSelection = (element, x, y) => {
    dispatch('selection', { x, y });
  };

  const resizeGrid = (width) => {
    fireResizeEvent = false;
    let now = Date.now();
    if (now - startTime > 100) {
      startTime = now;
    } else {
      return;
    }

    if (!fullWidth || !jExcelObj) return;
    if (width) {
      recalculateColumnWidth();
      columns.map((col, index) => {
        if (col.type !== 'hidden') {
          jExcelObj.setWidth(index, +col.width);
        }
      });
    }
  };

  $: if (data) {
    createGrid(data);
  }

  $: resizeGrid(containerWidth);

  $: if (mouseUp) {
    const keys = [];
    const values = [];
    fireResizeEvent = true;
    columns.map((col, index) => {
      keys.push('col' + index);
      values.push(`${col.width}`);
    });
    SettingsStore.saveUserSettings({
      menuPath,
      elementId: id,
      keys,
      values,
    });
  }

  export const refresh = () => {
    destroyGrid();
    createGrid(data);
  };

  export const getGridInstance = () => {
    return jExcelObj;
  };

  export const createCheckboxHeader = (col, onlyOneCheckbox = true) => {
    const checkboxTag = document.createElement('input');
    checkboxTag.type = 'checkbox';
    checkboxTag.title = T('SYS.LABEL.SELECT_UNSELECT_ALL');
    checkboxTag.onchange = (event) => {
      const checked = event.target.checked;
      const checkColumn = new Array(data.length).fill(checked);
      jExcelObj.setColumnData(col, checkColumn);
    };
    const td = document.querySelector(`td[data-x="${col}"]`);

    if (onlyOneCheckbox) {
      if (!td.querySelector('input[type="checkbox"]')) {
        td.prepend(checkboxTag);
      }
    } else {
      td.prepend(checkboxTag);
    }
  };

  export const createToggleCheckHeader = (col) => {
    const buttonTag = document.createElement('button');
    buttonTag.title = T('SYS.BUTTON.TOGGLE_SELECTION');
    buttonTag.className = 'btn-small-primary';
    buttonTag.innerHTML = '<i class="fa fa-toggle-on"></i>';
    buttonTag.style = 'padding: 0; font-size: 0.8rem;';
    buttonTag.onclick = (event) => {
      const checkColumn = jExcelObj.getColumnData(col).map((it) => !it);
      jExcelObj.setColumnData(col, checkColumn);
    };
    document.querySelector(`td[data-x="${col}"]`).prepend(buttonTag);
  };

  export const hideColumn = (col) => {
    if (jExcelObj) {
      jExcelObj.hideColumn(col);
    }
  };

  export const showColumn = (col) => {
    if (jExcelObj) {
      jExcelObj.showColumn(col);
    }
  };
</script>

<style lang="scss">
  .grid-content {
    display: flex;
    flex-direction: column;
    align-items: start;
    border: 1px sloid gray;
  }
</style>

<div class="grid-content">
  <slot name="label" />
  <div bind:this={gridRef} style="width: 100%; height: 100%;" {id} />
</div>
