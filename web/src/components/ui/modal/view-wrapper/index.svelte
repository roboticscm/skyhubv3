<script>
    import Modal from 'src/components/ui/modal/base/index.svelte';
    export let id;
    export let title;
    export let menuPath;
    export let defaultWidth = 500;
    export let defaultHeight = 300;
    export let menuInfo;
  

    let modalRef;


    export const show = () => {
      return modalRef.show();
    };

  </script>
  
  <Modal
    wrapperClass="high-z-index"
    {menuPath}
    {defaultWidth}
    {defaultHeight}
    contentClass="full-modal-content"
    fontIcon={menuInfo && menuInfo.fontIcon}
    {title}
    {id}
    showControlButton={false}
    bind:this={modalRef}>
    <slot />
  </Modal>