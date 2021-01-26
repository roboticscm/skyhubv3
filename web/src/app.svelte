<script>
  import { onMount } from 'svelte';
  import LoginPage from 'src/features/system/auth/login.svelte';
  import LoadingPage from 'src/pages/loading/index.svelte';
  import { Authentication } from 'src/lib/authentication';

  onMount(() => {
    document.body.removeChild(document.getElementById('loadScreen'));
    document.body.style.cursor = 'auto';
  });
</script>

{#if Authentication.isLoggedIn()}
  <LoadingPage />
{:else}
  <LoginPage />
{/if}
