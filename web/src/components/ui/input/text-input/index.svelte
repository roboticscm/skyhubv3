<script>
  import { App } from 'src/lib/constants';
  export let name;
  export let disabled = false;
  export let className = 'form-control';
  export let autocomplete = App.AUTO_COMPLETE;
  export let value;
  let inputRef;
  export const focus = () => {
    if (inputRef) {
      inputRef.focus();
    }
  };
</script>

<input {name} type="text" {disabled} class={className} bind:value {autocomplete} bind:this={inputRef} />
