<script>
  import Item from './role-control-item.svelte';
  import Button from 'src/components/ui/button/flat-button';
  import { ButtonType } from 'src/components/ui/button/types';

  export let next$;
  export let role;
  export let orgMenuList;
  console.log(orgMenuList.length);

  const onBack = () => {
    next$.next(false);
  };
</script>

<section class="view-content-controller" style="display: flex; justify-content: space-between; flex-wrap: nowrap">
  <div style="width: 70%; display: flex; flex-wrap: nowrap">
    <Button btnType={ButtonType.custom} text={'SYS.BUTTON.BACK'.t()} on:click={onBack} disabled={false} />
  </div>

  <div style="width: 30%; white-space: nowrap; text-align: right">
    
  </div>
</section>

{#each orgMenuList as orgMenu}
  <Item />
{/each}
