<script>
  import { createEventDispatcher } from 'svelte';

  export let text;
  export let selected = false;
  export let inline = true;

  const dispatch = createEventDispatcher();
  const onClick = () => {
    dispatch('click');
  };
</script>

<div
  class="{inline ? 'dropdown-item' : ''}
  {selected ? 'dropdown-content__selected' : ''}"
  on:click|stopPropagation={onClick}>
  <span style="white-space: nowrap">
    {@html text}
  </span>
  <slot />
</div>
