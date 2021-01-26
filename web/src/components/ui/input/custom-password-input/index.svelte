<script>
  import { createEventDispatcher } from 'svelte';
  import { StringUtil } from 'src/lib/string-util';
  import { passwordChar } from 'src/components/ui/input/autocomplete/helper';

  export let displayChar = passwordChar();
  export let name = '';
  export let value = '';

  const dispatch = createEventDispatcher();

  let memoryPassword = '';
  let inputRef;

  const onKeyup = (event) => {
    if (event.key === 'Backspace' || event.key === 'Delete') {
      const start = inputRef.selectionStart;
      const end = inputRef.selectionStart;
      if (start === 0 && end === 0) {
        memoryPassword = '';
      } else {
        memoryPassword = memoryPassword.slice(0, start) + memoryPassword.slice(start + 1, memoryPassword.length);
      }
    } else if (event.code.startsWith('Key') || event.code.startsWith('Digit')) {
      const pos = inputRef.selectionStart;
      memoryPassword = StringUtil.insertAt(memoryPassword, event.key, pos);
    }

    inputRef.value = new Array(inputRef.value.length).fill(displayChar).join('');
    dispatch('change', getPassword());
    value = getPassword();
  };

  export const getPassword = () => {
    return memoryPassword;
  };

  export const focus = () => {
    inputRef.focus();
  };

  export const clear = () => {
    inputRef.value = '';
    memoryPassword = '';
  };
</script>

<input autocomplete="off" {name} class="primary form-control" type="search" bind:this={inputRef} on:keyup={onKeyup} />
