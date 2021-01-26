<script>
  export let loading$;
  export let smallSize = false;
</script>

{#if $loading$}
  <div class="progress-bar-wrapper">
    <i class="progress-bar {smallSize ? 'small-progress-bar' : ''} fa fa-spinner fa-spin" />
  </div>
{/if}
