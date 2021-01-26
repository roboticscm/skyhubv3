<script>
  import Modal from 'src/components/ui/modal/base/index.svelte';
  import { T } from 'src/lib/locale';
  import { tick } from 'svelte';
  export let id;
  export let subTitle;
  export let containerWidth;
  export let menuPath;
  export let columns;

  let modalRef;
  let excelGridRef;
  let ExcelGridComponent;

  let height;
  let mouseUp;

  const createDynamicColumns = () => {
    const dynCols = [];
    columns.forEach((it) => {
      dynCols.push({
        type: 'text',
        title: T(`SYS.LABEL.${it.toUpperCase()}`),
        name: it,
        width: 100,
        readOnly: true,
      });
    });
    return dynCols;
  };

  let data;
  const fullColumns = [
    {
      type: 'hidden',
      name: 'id',
    },
    ...createDynamicColumns(),
    {
      type: 'text',
      title: T('SYS.LABEL.DELETED_BY'),
      name: 'deletedBy',
      width: 160,
      readOnly: true,
    },
    {
      type: 'text',
      title: T('SYS.LABEL.DELETED_AT'),
      name: 'deletedDate',
      width: 80,
      readOnly: true,
    },
    {
      type: 'checkbox',
      title: T('SYS.LABEL.RESTORE'),
      name: 'restore',
      width: 70,
    },
    {
      type: 'checkbox',
      title: T('SYS.LABEL.FOREVER_DELETE'),
      name: 'foreverDelete',
      width: 70,
    },
  ];

  export const show = (_data) => {
    data = _data;
    const h = modalRef.getHeight().replace('px', '');
    height = `${h - 120}px`;
    return new Promise((resolve, reject) => {
      import('src/components/ui/excel-grid/index.svelte').then((res) => {
        ExcelGridComponent = res.default;
        tick().then(() => {
          if (excelGridRef) {
            excelGridRef.createCheckboxHeader(fullColumns.length - 2, true);
            excelGridRef.createCheckboxHeader(fullColumns.length - 1, true);
          }
        });
        resolve(modalRef.show());
      });
    });
  };

  const onResize = (event) => {
    containerWidth = event.detail.width;
  };

  const onMouseUp = () => {
    mouseUp = Date.now();
  };

  export const getData = () => {
    return excelGridRef.getData();
  };

  const onChanged = (e) => {};
</script>

<Modal
  defaultWidth={800}
  defaultHeight={400}
  on:containerResize={onResize}
  on:mouseUp={onMouseUp}
  {menuPath}
  contentClass="full-modal-content"
  fontIcon="<i class='fa fa-trash-restore-alt'></i>"
  title={T('SYS.LABEL.TRASH_RESTORE') + ' - ' + subTitle}
  {id}
  bind:this={modalRef}>
  <svelte:component
    this={ExcelGridComponent}
    on:changed={onChanged}
    {mouseUp}
    {height}
    {menuPath}
    bind:this={excelGridRef}
    id={'grid' + id}
    columns={fullColumns}
    {data}
    {containerWidth}
    fullWidth={true}>
    <span slot="label" class="label">{T('SYS.LABEL.DELETED_ITEMS')}:</span>
  </svelte:component>
</Modal>
