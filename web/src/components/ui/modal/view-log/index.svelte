<script>
  import Modal from 'src/components/ui/modal/base/index.svelte';
  import { T } from 'src/lib/locale';
  import QuickSearch from 'src/components/ui/float-input/quick-search';
  import FloatDatePicker from 'src/components/ui/float-input/date-picker';
  import Error from 'src/components/ui/error';
  import { SkyLogFilter } from '../types';
  import Form from 'src/lib/form/form';
  import { SkyLogStore } from 'src/store/skylog';
  import { LoginInfo } from 'src/store/login-info';
  import { SDate } from 'src/lib/sdate';
  import ViewLogDetailsModal from '../view-log-details/index.svelte';

  const defaultWidth = 800;
  const defaultHeight = 400;

  export let id;
  export let subTitle;
  export let containerWidth;
  export let menuPath;

  let modalRef;
  let excelGridRef;
  let viewLogDetailsModalRef;
  let ExcelGridComponent;
  let height;

  let data;
  const columns = [
    {
      type: 'hidden',
      name: 'id',
    },
    {
      type: 'text',
      title: T('SYS.LABEL.DATE'),
      name: 'date',
      width: 80,
      readOnly: true,
    },
    {
      type: 'text',
      title: T('SYS.LABEL.USER'),
      name: 'user',
      width: 80,
      readOnly: true,
    },
    {
      type: 'text',
      title: T('SYS.LABEL.ACTION'),
      name: 'action',
      width: 80,
      readOnly: true,
    },
    {
      type: 'text',
      title: T('SYS.LABEL.OBJECT'),
      name: 'shortDescription',
      width: 120,
      readOnly: true,
    },
    {
      type: 'text',
      title: T('SYS.LABEL.REASON'),
      name: 'reason',
      width: 120,
      readOnly: true,
    },
    {
      type: 'hidden',
      name: 'description',
    },
    {
      type: 'text',
      title: T('SYS.LABEL.VIEW'),
      name: 'view',
      width: 80,
      readOnly: true,
    },
  ];

  const resetForm = () => {
    return new Form(new SkyLogFilter());
  };
  let form = resetForm();

  const calcHeight = () => {
    const h = modalRef.getHeight().replace('px', '');
    height = `${h - 100}px`;
  };
  export const show = (_data) => {
    data = _data;
    calcHeight();
    return new Promise((resolve, reject) => {
      import('src/components/ui/selectable-table/index.svelte').then((res) => {
        ExcelGridComponent = res.default;

        resolve(modalRef.show());
      });
    });
  };

  const onResize = (event) => {
    containerWidth = event.detail.width;
    calcHeight();
  };

  export const getData = () => {
    return excelGridRef.getData();
  };

  const onTableClick = (e) => {
    if (e.detail.data.length > 0) {
      viewLogDetailsModalRef.show(e.detail.data[0].shortDescription, e.detail.data[0].description);
    }
  };

  $: {
    SkyLogStore.findLog(LoginInfo.menuPath$.value, form.startDate, form.endDate).subscribe((res) => {
      data = res.data ? res.data.map((row) => {
        row.date = row.date ? SDate.convertMillisecondToDateTimeString(parseInt(row.date)) : '';
        row.action = JSON.parse(row.description).action;
        row.view = T('SYS.LABEL.VIEW');
        return row;
      }) : [];
    });
  }
</script>

<Modal
  {defaultWidth}
  {defaultHeight}
  on:containerResize={onResize}
  {menuPath}
  showOkButton={false}
  cancelButtonTitle={T('SYS.BUTTON.CLOSE')}
  contentClass="full-modal-content"
  fontIcon="<i class='fas fa-book-medical'></i>"
  title={T('SYS.LABEL.VIEW_LOG') + ' - ' + subTitle}
  {id}
  bind:this={modalRef}>
  <svelte:component
    this={ExcelGridComponent}
    on:click={onTableClick}
    {height}
    {menuPath}
    bind:this={excelGridRef}
    id={'grid' + id}
    {columns}
    {data}
    {containerWidth}
    fullWidth={true}>
    <div style="display: flex; padding-bottom: 6px;" slot="header" let:filter>
      <form style="width: 100%;" class="form" on:keydown={(event) => form.errors.clear(event.target.name)}>
        <div class="row">
          <div class="col-xs-24 col-sm-10">
            <FloatDatePicker
              dateRange={true}
              timePicker={false}
              bind:startValue={form.startDate}
              bind:endValue={form.endDate}
              placeholder={T('SYS.LABEL.DATE_RANGE')} />
            <Error {form} field="startDate" />
          </div>

          <div class="col-xs-24 col-sm-14">
            <QuickSearch on:input={(e) => filter(e.target.value)} />
          </div>
        </div>
      </form>
    </div>
  </svelte:component>
</Modal>
<ViewLogDetailsModal id={id + 'Details'} bind:this={viewLogDetailsModalRef} {menuPath} />
