<script>
  import Modal from 'src/components/ui/modal/base/index.svelte';
  import { T } from 'src/lib/locale';
  import JsonViewer from 'json-viewer-js';
  import { SJSON } from 'src/lib/sjson';

  const defaultWidth = 800;
  const defaultHeight = 400;

  export let id;
  export let containerWidth;
  export let menuPath;

  let modalRef;
  let title;

  export const show = (_title, json) => {
    title = _title;
    document.querySelector('#jsonView').innerHTML = '';
    new JsonViewer({
      container: document.querySelector('#jsonView'),
      data: SJSON.stringify(SJSON.parse(json)),
      theme: 'light',
      expand: true,
    });
    modalRef.show();
  };

  const onResize = (event) => {
    containerWidth = event.detail.width;
  };
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
  title={T('SYS.LABEL.LOG_DETAILS') + (title ? ' - ' + title : '')}
  {id}
  bind:this={modalRef}>
  <div id="jsonView" />

</Modal>
