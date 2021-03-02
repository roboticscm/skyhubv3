<script>
  export let name = '';
  export let disabled = false;
  export let className = '';
  export let checked;
  export let text = '';
  let inputRef;

  export const focus = () => {
    if (inputRef) {
      inputRef.focus();
    }
  };
</script>

<input {name} type="checkbox" {disabled} class={className} bind:checked bind:this={inputRef} on:change />
<label for={name} class={disabled ? 'readonly' : ''}>{text}</label>
