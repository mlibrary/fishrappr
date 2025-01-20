const DOMAIN = 'digital.bentley.umich.edu';

$(document).ready(function() {
  fetch(`https://staff.lib.umich.edu/api/alerts?now=${Date.now()}`)
    .then(response => response.json())
    .then((payload) => {
      for(let i = 0; i < payload.length; i++) {
        const message = payload[i];
        if ( message.domains ==  DOMAIN ) {
          const $alert = `<section class="banner--warning" role="status" style="color: #212B36; padding: 0.5rem 0; background-color: #FF8A58; font-size: 16px;">
        <div class="website-alert" style="width: auto; padding: 0 1rem;">
          <style>
            .website-alert p { margin: 0; }
          </style>
          <div class="banner__inner-container" style="display: flex; gap: 0.5rem; align-items:flex-start;">
            <svg xmlns="http://www.w3.org/2000/svg" height="16px" viewBox="0 0 24 24" width="16px" fill="currentColor" focusable="false" aria-hidden="true" style="flex-shrink: 0;margin-top:.25rem"">
              <title>Warning Alert</title>
              <path d="M0 0h24v24H0z" fill="none" />
              <path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z" />
            </svg>
            ${message.html}
          </div>
        </div>
      </section>
    `;
          $("#header-navbar").before($alert);
          break;
        }
      }
    });
})

