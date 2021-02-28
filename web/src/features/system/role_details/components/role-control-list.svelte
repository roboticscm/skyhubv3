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

  <div style="width: 30%; white-space: nowrap; text-align: right" />
</section>
<div class="row" style="grid-column-gap:5px">
  {#each orgMenuList as orgMenu}
    <div class="col-xs-24 col-md-12 col-lg-8 mx-xs-0 px-xs-0 mb-xs-1 mr-md-0">
      <Item {role} {orgMenu}/>
    </div>
  {/each}
</div>
