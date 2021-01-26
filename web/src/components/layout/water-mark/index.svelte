<script>
  import { Authentication } from 'src/lib/authentication';
</script>

<div class="water-mark">
  {#if Authentication.getUsername()}
    {@html '(' + Authentication.getUsername() + ')'}
  {/if}
</div>
