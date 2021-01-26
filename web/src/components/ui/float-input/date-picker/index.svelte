<script>
  import { onMount, tick, createEventDispatcher } from 'svelte';
  import 'src/lib/vendor/daterangepicker';
  import { App } from 'src/lib/constants';
  import { T } from 'src/lib/locale';
  import { SDate } from 'src/lib/sdate';
  import moment from 'moment';

  export let name = undefined;
  export let disabled = false;
  export let className = '';
  export let autocomplete = App.AUTO_COMPLETE;
  export let placeholder = '';
  export let checked = undefined;
  export let rightCheck = false;
  export let title = '';
  export let checkTitle = '';
  export let dateRange = false;
  export let timePicker = true;
  export let startValue = null;
  export let endValue = null;

  const dispatch = createEventDispatcher();

  let currentStartDate = startValue;
  let currentEndDate = endValue;

  let inputRef;
  export const focus = () => {
    if (inputRef) {
      inputRef.focus();
    }
  };

  const onCheck = () => {
    inputRef && inputRef.focus();
  };

  onMount(() => {
    window['$'](inputRef).daterangepicker(
      {
        singleDatePicker: !dateRange,
        timePicker: true,
        opens: 'center',
        drops: 'down',
        ranges: {
          [T('SYS.LABEL.TODAY')]: [moment(), moment()],
          [T('SYS.LABEL.TOMORROW')]: [moment().add(1, 'days'), moment().add(1, 'days')],
          [T('SYS.LABEL.NEXT_WEEK')]: [moment().add(6, 'days'), moment()],
          [T('SYS.LABEL.NEXT_MONTH')]: [
            moment()
              .add(1, 'month')
              .startOf('month'),
            moment()
              .add(1, 'month')
              .endOf('month'),
          ],
          ['--------']: [''],
          [T('SYS.LABEL.YESTERDAY')]: [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
          [T('SYS.LABEL.LAST_WEEK')]: [moment().subtract(6, 'days'), moment()],
          [T('SYS.LABEL.THIS_MONTH')]: [moment().startOf('month'), moment().endOf('month')],
          [T('SYS.LABEL.LAST_MONTH')]: [
            moment()
              .subtract(1, 'month')
              .startOf('month'),
            moment()
              .subtract(1, 'month')
              .endOf('month'),
          ],
        },
        locale: {
          format: timePicker ? 'DD/MM/YYYY hh:mm A' : 'DD/MM/YYYY',
          separator: ' - ',
          applyLabel: T('SYS.BUTTON.APPLY'),
          cancelLabel: T('SYS.BUTTON.CLEAR'),
          fromLabel: T('SYS.LABEL.FROM'),
          toLabel: T('SYS.LABEL.TO'),
          customRangeLabel: T('SYS.LABEL.CUSTOM'),
          weekLabel: 'W',
          daysOfWeek: [
            T('SYS.LABEL.SU'),
            T('SYS.LABEL.MO'),
            T('SYS.LABEL.TU'),
            T('SYS.LABEL.WE'),
            T('SYS.LABEL.TH'),
            T('SYS.LABEL.FR'),
            T('SYS.LABEL.SA'),
          ],
          monthNames: [
            T('SYS.LABEL.JANUARY'),
            T('SYS.LABEL.FEBRUARY'),
            T('SYS.LABEL.MARCH'),
            T('SYS.LABEL.APRIL'),
            T('SYS.LABEL.MAY'),
            T('SYS.LABEL.JUNE'),
            T('SYS.LABEL.JULY'),
            T('SYS.LABEL.AUGUST'),
            T('SYS.LABEL.SEPTEMBER'),
            T('SYS.LABEL.OCTOBER'),
            T('SYS.LABEL.NOVEMBER'),
            T('SYS.LABEL.DECEMBER'),
          ],
          firstDay: 1,
        },
        startDate: startValue,
        endDate: endValue,
      },
      function(start, end, label) {
        currentStartDate = timePicker ? start.toDate() : start.startOf('day');
        currentEndDate = timePicker ? end.toDate() : end.startOf('day');
        startValue = timePicker ? start.valueOf() : start.startOf('day').valueOf();
        endValue = timePicker ? end.valueOf() : end.startOf('day').valueOf();
        dispatch('change', { startValue, endValue });
      },
    );

    window['$'](inputRef).on('cancel.daterangepicker', function(ev, picker) {
      clearDate();
    });

    window['$'](inputRef).on('show.daterangepicker', function(ev, picker) {
      const height = window['$'](picker.container[0]).height();
      const windowHeight = window.innerHeight;
      const top = +picker.container[0].style.top.replace('px', '');

      if (top + height > windowHeight) {
        picker.container[0].style.top = `${(windowHeight - height) / 2}px`;
      }
    });

    // window['$'](inputRef).on('hide.daterangepicker', function(ev, picker) {
    //   const height = window['$'](picker.container[0]).height();
    //   const windowHeight = window.innerHeight;
    //   const top = +picker.container[0].style.top.replace('px', '');
    //
    //   if(top === 0) {
    //     picker.drops = 'up';
    //   }
    //
    //   if (top < 0) {
    //     picker.drops = 'down';
    //   }
    // });
  });

  export const clearDate = () => {
    window['$'](inputRef).val('');
    currentStartDate = null;
    currentEndDate = null;
    startValue = null;
    endValue = null;
    dispatch('change', { startValue, endValue });
  };

  export const setStartValueInTimestamp = (timestamp) => {
    tick().then(() => {
      const ele = window['$'](inputRef).data('daterangepicker');
      if (timestamp) {
        ele && ele.setStartDate(new Date(timestamp));
        currentStartDate = new Date(timestamp);
      } else {
        clearDate();
      }
    });
  };

  export const setEndValueInTimestamp = (timestamp) => {
    tick().then(() => {
      const ele = window['$'](inputRef).data('daterangepicker');
      if (timestamp) {
        ele && ele.setEndDate(new Date(timestamp));
        currentEndDate = new Date(timestamp);
      } else {
        clearDate();
      }
    });
  };

  export const getStartValueInTimestamp = () => {
    return currentStartDate && currentStartDate.getTime();
  };

  export const getEndValueInTimestamp = () => {
    return currentEndDate && currentEndDate.getTime();
  };

  export const getStartDateValue = () => {
    return currentStartDate && SDate.toDateString(currentStartDate);
  };

  export const getEndDateValue = () => {
    return currentEndDate && SDate.toDateString(currentEndDate);
  };

  export const getStartDateTimeValue = () => {
    return currentStartDate && SDate.toDateTimeString(currentStartDate);
  };

  export const getEndDateTimeValue = () => {
    return currentEndDate && SDate.toDateTimeString(currentEndDate);
  };

  $: setStartValueInTimestamp(startValue);
  $: setEndValueInTimestamp(endValue);
</script>

<div class="floating-wrapper">
  <input
    style="color: var(--primary)"
    {title}
    {name}
    type="text"
    {disabled}
    class="{checked !== undefined ? 'check' : ''}
    {rightCheck ? 'right' : ''}
    {className} floating__input"
    {autocomplete}
    bind:this={inputRef}
    {placeholder} />
  <!-- svelte-ignore a11y-label-has-associated-control -->
  <label class="floating__label" data-content={placeholder} />
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
