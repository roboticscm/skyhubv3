<script>
  import { createEventDispatcher } from 'svelte';
  import SearchIcon from 'src/icons/search.svelte';
  import { App } from 'src/lib/constants';
  import { BehaviorSubject } from 'rxjs';
  import { T } from 'src/lib/locale';

  export let placeholder = '';
  export let action = undefined;
  export let showAdvancedSearch = false;
  export let loading$ = new BehaviorSubject(false);
  export let title = `
    ${T('SYS.LABEL.SEARCH_ALL')}: ${T('SYS.LABEL.ADD_BEFORE')} @*
    ${T('SYS.LABEL.SEARCH_EXACTLY')}: ${T('SYS.LABEL.ADD')} #
    ---------------------------
    ${T('SYS.LABEL.FULL_TEXT_SEARCH_OPTION')}:
    1. ${T('SYS.LABEL.EXACT')}: ${T('SYS.LABEL.START_WITH')} " -> ${T('SYS.LABEL.EX')}: "some text
    2. ${T('SYS.LABEL.SEARCH_OR')}: | -> ${T('SYS.LABEL.EX')}: some | text
    3. ${T('SYS.LABEL.ADVANCED')}: ${T('SYS.LABEL.START_WITH')} \` -> ${T(
    'SYS.LABEL.EX',
  )}: \`Word<n>OtherWord (n: number)
  `;
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

<div class="quick-search-wrapper">
  <input
    {title}
    on:input
    required
    use:useAction
    type="search"
    class="quick-search-input"
    bind:this={inputRef}
    {placeholder} />
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
