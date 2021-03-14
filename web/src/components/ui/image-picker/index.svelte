<script>
import { createEventDispatcher } from "svelte";
import { getFileExtension } from "src/lib/file";


  export let src;
  export let disabled = false;
  export let id;
  export let acceptExt = "image/x-png,image/gif,image/jpeg";
  export let maxSize = 0;
  export let outExt = "";
  export let outSize = 0;
  export let outType = "";

  const dispatch = createEventDispatcher();

  $: if (!src && fileRef) {
    fileRef.value = '';
  }
  let fileRef, imageRef, imageWrapperRef;
  const onSelectFile = (event) => {
    event.preventDefault();
    fileRef.click();
  };

  const onClearImage = (event) => {
    event.preventDefault();
    src = undefined;
    fileRef.value = '';
  };

  const onImageError = () => {
    src = undefined;
  };

  $: {
    if (imageWrapperRef) {
      if (disabled) {
        imageWrapperRef.classList.remove('image-hover');
      } else {
        imageWrapperRef.classList.add('image-hover');
      }
    }
  }

  const onChangeFile = (e) => {
    if (e.target.files.length > 0) {
      const file = e.target.files[0];
      if (maxSize > 0 && file.size > maxSize) {
        dispatch('error', 'SYS.MSG.FILE_TOO_LARGE');
        return;
      }
      outType = file.type;
      outSize = file.size;
      outExt = getFileExtension(file.name);

      const reader = new FileReader();
        reader.onloadend = function() {
          src = reader.result;
        };
        reader.readAsDataURL(file);
    }
  };
</script>

<div class="image-viewer image-hover" bind:this={imageWrapperRef}>
  <img on:error={onImageError} class={src ? 'image' : 'hide'} bind:this={imageRef} {src} alt="" />
  <div class={src ? 'hide' : 'no-image'} />
  <input style="display: none;" type="file" {id} bind:this={fileRef} on:change={onChangeFile} accept={acceptExt} />
  <div class="overlap">
    <div class="overlap__content">
      <button type="button" class="btn-small-success" {disabled} on:click={onSelectFile}>
        <i class="fa fa-cloud-upload-alt" />
      </button>
      <button type="button" class="btn-small-danger" {disabled} on:click={onClearImage}>
        <i class="fa fa-times" />
      </button>
    </div>
  </div>
</div>
