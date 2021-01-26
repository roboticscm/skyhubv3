<script>
  import { App } from 'src/lib/constants';
  export let name = undefined;
  export let disabled = false;
  export let className = '';
  export let autocomplete = App.AUTO_COMPLETE;
  export let value = undefined;
  export let placeholder;
  export let checked = undefined;
  export let rightCheck = false;
  export let title = '';
  export let checkTitle = '';
  export let readonly = false;

  let inputRef;
  export const focus = () => {
    if (inputRef) {
      inputRef.focus();
    }
  };

  const onCheck = () => {
    inputRef && inputRef.focus();
  };
</script>

<div class="floating-wrapper">
  <input
    title={title ? title : value}
    {name}
    type="search"
    {readonly}
    {disabled}
    class="{checked !== undefined ? 'check' : ''}
    {rightCheck ? 'right' : ''} floating__input {className}"
    bind:value
    {autocomplete}
    bind:this={inputRef}
    {placeholder}
    required />
  <label for={name} class="floating__label" data-content={placeholder} />
  {#if checked !== undefined}
    <input
      title={checkTitle}
      class={rightCheck ? 'right' : ''}
      tabindex="-1"
      {disabled}
      bind:checked
      type="checkbox"
      on:change={onCheck} />
  {/if}
</div>
