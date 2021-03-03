<script>
  import { onMount, tick } from 'svelte';
  import { take } from 'rxjs/operators';
  import { ViewStore } from 'src/store/view';
  import { ButtonType, ButtonId } from 'src/components/ui/button/types';
  import Button from 'src/components/ui/button/flat-button';
  import ProgressBar from 'src/components/ui/progress-bar';
  import { Store } from './store';
  import { App } from 'src/lib/constants';
  import { BehaviorSubject } from 'rxjs';
  import { RxHttp } from 'src/lib/rx-http';
  import { BaseUrl } from 'src/lib/constants';

  // Props
  export let showTitle = true;
  export let menuPath;
  export let fullControl;
  export let roleControls;
  export let callFrom = 'Self';
  export let showWorkList = false;
  export let selectedId;
  export let searchFields;

  selectedId;
  searchFields;
  showTitle;
  callFrom;
  showWorkList;

  let viewWrapperModalRef,
    modalContentViewRef,
    modalMenuPath,
    orgRoleTreeRef,
    filterOrgTreeRef,
    orgMenuTreeRef,
    next$ = new BehaviorSubject(undefined);

  let nexting = false,
    loadingFilterOrg = false,
    loadingOrgMenu = false;
  // Init view
  const view = new ViewStore(menuPath);
  view.fullControl = fullControl;
  view.roleControls = roleControls;
  export const getView = () => view;

  const { ModalContentView$, modalFullControl$, modalRoleControls$, isReadOnlyMode$, copying$ } = view;

  const store = new Store(view);

  const onGateClick = (event) => {
    RxHttp.get({
      baseUrl: BaseUrl.CONTROL,
      url: `SET?${event}`,
    }).subscribe((res) => {
      console.log(res);
    });

    setTimeout(() => {
      RxHttp.get({
        baseUrl: BaseUrl.CONTROL,
        url: `CLR?${event}`,
      }).subscribe((res) => {
        console.log(res);
      });
    }, 500);
  };
</script>

<ProgressBar loading$={view.loading$} />
<svelte:head>
  <title>{`${App.NAME} - ${view.getViewTitle()}`}</title>
</svelte:head>
<section class="view-container">

  <section class="view-content-main">
    <div class="row" style="grid-column-gap:5px">
      <div class="col-xs-24 col-md-12 col-lg-6 mx-xs-0 px-xs-0 mb-xs-1 mr-md-0 gates">
        <div class="gates__title">{'IOT.LABEL.GATES'.t()}</div>
        <div class="gates__content default-rounded-border">
          <div class="gates__left">
            <div class="gates__left__entrance">
              <div class="default-padding center-box bottom-border">{'IOT.LABEL.ENTRANCE_GATE'.t()}</div>
              <div class="gates__left__entrance__bottom">
                <div class="default-padding center-box">
                  <Button isOn={true} btnType={ButtonType.controlA} on:click={() => onGateClick('A')} />
                </div>
                <div class="default-padding center-box">
                  <Button btnType={ButtonType.controlA} on:click={() => onGateClick('B')} />
                </div>
                <div class="default-padding center-box">
                  <Button btnType={ButtonType.controlA} on:click={() => onGateClick('C')} />
                </div>
              </div>
            </div>
            <div class="gates__left__bottom">
              <div class="gates__left__bottom__main center-box">
                <div class="in-box default-padding bottom-border">{'IOT.LABEL.MAIN'.t()}</div>
                <div class="w-100">
                  <div class="default-padding center-box">
                    <Button btnType={ButtonType.controlA} on:click={() => onGateClick('D')} />
                  </div>
                  <div class="default-padding center-box">
                    <Button btnType={ButtonType.controlA} on:click={() => onGateClick('E')} />
                  </div>
                  <div class="default-padding center-box">
                    <Button btnType={ButtonType.controlA} on:click={() => onGateClick('F')} />
                  </div>
                </div>
              </div>
              <div class="gates__left__bottom__main center-box">
                <div class="in-box default-padding bottom-border">{'IOT.LABEL.BASEMENT'.t()}</div>
                <div class="w-100">
                  <div class="default-padding center-box">
                    <Button btnType={ButtonType.controlA} on:click={() => onGateClick('G')} />
                  </div>
                  <div class="default-padding center-box">
                    <Button btnType={ButtonType.controlA} on:click={() => onGateClick('H')} />
                  </div>
                  <div class="default-padding center-box">
                    <Button btnType={ButtonType.controlA} on:click={() => onGateClick('I')} />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="gates__right center-box">
            <div class="in-box default-padding bottom-border">{'IOT.LABEL.ALL_GATES'.t()}</div>
            <div class="h-100 w-100 gates__right__bottom">
              <div class="default-padding center-box">
                <Button btnType={ButtonType.controlA} on:click={() => onGateClick('ADG')} />
              </div>
              <div class="default-padding center-box">
                <Button btnType={ButtonType.controlA} on:click={() => onGateClick('BEH')} />
              </div>
              <div class="default-padding center-box">
                <Button btnType={ButtonType.controlA} on:click={() => onGateClick('CFI')} />
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="center-box col-xs-24 col-md-12 col-lg-6 mx-xs-0 px-xs-0 mb-xs-1 mr-md-0 default-rounded-border">
        Item 2
      </div>
      <div class="center-box col-xs-24 col-md-12 col-lg-6 mx-xs-0 px-xs-0 mb-xs-1 mr-md-0 default-rounded-border">
        Item 3
      </div>
      <div class="center-box col-xs-24 col-md-12 col-lg-6 mx-xs-0 px-xs-0 mb-xs-1 mr-md-0 default-rounded-border">
        Item 4
      </div>
    </div>
  </section>
</section>
