<script>
  import { App } from 'src/lib/constants';
  export let name;
  export let disabled = false;
  export let className = '';
  export let autocomplete = App.AUTO_COMPLETE;
  export let value = undefined;
  export let placeholder;
  export let checked = undefined;
  export let rightCheck = false;
  export let title = '';
  export let checkTitle = '';
  export let min = 0;
  export let max = undefined;

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
    on:keyup
    {min}
    {max}
    {title}
    {name}
    type="number"
    {disabled}
    class="{checked !== undefined ? 'check' : ''}
    {rightCheck ? 'right' : ''}
    {className} floating__input"
    bind:value
    {autocomplete}
    bind:this={inputRef}
    {placeholder} />
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
