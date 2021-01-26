<script>
  export let form;
  export let field;
  export let className = 'error';
</script>

{#if form.errors.has(field)}
  <span class={className}>{form.errors.get(field)}</span>
{/if}
