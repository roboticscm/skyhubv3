<script>
  import { createEventDispatcher } from 'svelte';
  import SearchIcon from 'src/icons/search.svelte';
  import { App } from 'src/lib/constants';
  import { BehaviorSubject } from 'rxjs';

  export let placeholder = '';
  export let action = undefined;
  export let showAdvancedSearch = false;
  export let loading$ = new BehaviorSubject(false);

  let inputRef;

  const dispatch = createEventDispatcher();

  export const getTextSearch = () => {
    return inputRef.value;
  };

  const useAction = (component, param) => {
    if (action) {
      action.register(component, param);
    }
  };

  export const focus = () => {
    inputRef.focus();
  };

  const onMouseoverAdvanced = () => {
    dispatch('mouseoverAdvanced');
  };

  const onMouseoutAdvanced = () => {
    dispatch('mouseoutAdvanced');
  };

  const onClickAdvanced = () => {
    dispatch('clickAdvanced');
  };
</script>

<div class="quick-search-wrapper" style="margin-top: 20px;">
  <input required use:useAction on:input type="search" class="quick-search-input" bind:this={inputRef} {placeholder} />
  <!--  <i class="search-icon fa fa-search" />-->
  <div class="search-icon">
    <SearchIcon />
  </div>

  {#if $loading$}
    <div class="search-progress">
      {@html App.PROGRESS_BAR}
    </div>
  {/if}
  {#if showAdvancedSearch}
    <i
      on:click={onClickAdvanced}
      on:mouseover={onMouseoverAdvanced}
      on:mouseout={onMouseoutAdvanced}
      class="advanced-icon fa fa-chevron-down">
      <slot />
    </i>
  {/if}
</div>
