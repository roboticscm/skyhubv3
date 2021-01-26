<script>
  export let min = 1;
  export let max = 10;
  export let value = min;

  let inputRef;
  export const setValue = (value) => {
    if (inputRef) {
      inputRef.value = value;
    }
  };
</script>

<input bind:this={inputRef} type="range" {min} {max} class="full-width slider" on:input bind:value />
