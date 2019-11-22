/* eslint-disable */
import configMerger from '../util/configMerger';

const CONFIG = 'cfm';
const APP_TITLE = 'Digitransit';
const APP_DESCRIPTION = 'Digitransit';

const API_URL = 'https://api.digitransit.codeformuenster.org';
const MAP_URL = 'https://maps.wikimedia.org/osm-intl/';
const GEOCODING_BASE_URL = 'https://pelias.locationiq.org/v1';
const LOCATIONIQ_API_KEY = process.env.LOCATIONIQ_API_KEY;

const walttiConfig = require('./waltti').default;

const minLat = 51.4807;
const maxLat = 52.4711;
const minLon = 6.3863;
const maxLon = 8.3180;

export default configMerger(walttiConfig, {
  CONFIG,

  URL: {
    OTP: 'https://api.digitransit.codeformuenster.org/routing/v1/routers/cfm/',
    MAP: {
      default: MAP_URL,
    },
    STOP_MAP: `${API_URL}/map/v1/stop-map/`,
    // FIXME api-key via url
    PELIAS: `${GEOCODING_BASE_URL}/search${LOCATIONIQ_API_KEY ? '?api_key=' + LOCATIONIQ_API_KEY : ''}`,
    PELIAS_REVERSE_GEOCODER: `${GEOCODING_BASE_URL}/reverse${LOCATIONIQ_API_KEY ? '?api_key=' + LOCATIONIQ_API_KEY : ''}`,
  },

  appBarLink: { name: 'cfm', href: 'https://codeformuenster.org/' },

  colors: {
    primary: '$livi-blue',
  },

//   socialMedia: {
//     title: APP_TITLE,
//     description: APP_DESCRIPTION,
//   },

  socialMedia: {
    title: APP_TITLE,
    description: APP_DESCRIPTION,

    image: {
      url: '/img/hsl-social-share.png',
      width: 400,
      height: 400,
    },

    twitter: {
      card: 'summary',
      site: '@codeformuenster',
    },
  },

  title: APP_TITLE,

  textLogo: true,


  availableLanguages: ['de', 'en'],
  defaultLanguage: 'de',
  // This timezone data will expire on 31.12.2020
  // https://momentjs.com/timezone/docs/#/data-formats/packed-format/
  // timezoneData:
  //   'Europe/Helsinki|EET EEST|-20 -30|01010101010101010101010|1BWp0 1qM0 WM0 1qM0 ' +
  //   'WM0 1qM0 11A0 1o00 11A0 1o00 11A0 1o00 11A0 1qM0 WM0 1qM0 WM0 1qM0 11A0 1o00 11A0 1o00|35e5',

  mainMenu: {
    // Whether to show the left menu toggle button at all
    show: true,
    showDisruptions: true,
    showLoginCreateAccount: true,
    showOffCanvasList: true,
  },

  // mainMenu: {
  //   // Whether to show the left menu toggle button at all
  //   show: true,
  //   showDisruptions: false,
  //   showLoginCreateAccount: false,
  //   showOffCanvasList: true,
  // },

  feedIds: ['STWMS'],

  realTime: {
    STWMS: {
      active: true,
      gtfsrt: true,
      credentials: { username: 'user', password: 'userpass' },
      mqtt: 'wss://mosquitto.digitransit.codeformuenster.org/mqtt',
      routeSelector (routePageProps) {
        const route = routePageProps.route.gtfsId.split(':');
        return route[1];
      },
      mqttTopicResolver: (
        route,
        direction,
        tripStartTime,
        headsign, // eslint-disable-line no-unused-vars
        feedId, // eslint-disable-line no-unused-vars
        tripId, // eslint-disable-line no-unused-vars
        geoHash, // eslint-disable-line no-unused-vars
      ) => {
        // console.log('resolver', { route, direction, tripStartTime, headsign, feedId, tripId, geoHash });
        return (
          `/gtfsrt/vp/${feedId}/+/+/+/${
            route
          }/${
            direction
          }/+/${
            tripStartTime
          }/#`
        );
      },
    },
  },

  searchParams: {
    'boundary.rect.min_lat': minLat,
    'boundary.rect.max_lat': maxLat,
    'boundary.rect.min_lon': minLon,
    'boundary.rect.max_lon': maxLon,
  },

  areaPolygon: [
    [minLon, minLat],
    [minLon, maxLat],
    [maxLon, maxLat],
    [maxLon, minLat],
  ],

  defaultEndpoint: {
    address: 'Domplatz',
    lat: 51.9625,
    lon: 7.626,
  },

  defaultOrigins: [
    { 
      icon: 'icon-icon_star', 
      label: 'Bült', 
      lat: 51.9635, 
      lon: 7.6314
    }, { 
      icon: 'icon-icon_rail', 
      label: 'Hauptbahnhof', 
      lat: 51.9568,
      lon: 7.63415
    }, { 
      icon: 'icon-icon_star', 
      label: 'Coesfelder Kreuz', 
      lat: 51.9649,
      lon: 7.6
    },
  ],

  showAllBusses: true,
  showVehiclesOnStopPage: true,
  showRouteInformation: true,

  map: {
    useRetinaTiles: true,
    tileSize: 256,
    zoomOffset: 0,
  },

  footer: {
    content: [
      { label: `cfm ${walttiConfig.YEAR}` },
      {},
      {
        name: 'footer-feedback',
        nameEn: 'Submit feedback',
        href: 'https://github.com/codeformuenster/digitransit-ui/issues',
        icon: 'icon-icon_speech-bubble',
      },
      // {
      //   name: 'about-this-service',
      //   nameEn: 'About this service',
      //   route: '/tietoja-palvelusta',
      //   icon: 'icon-icon_info',
      // },
    ],
  },

  aboutThisService: {
    fi: [
      {
        header: 'Tietoja palvelusta',
        paragraphs: [
          'Tämän palvelun tarjoaa Cfm reittisuunnittelua varten Cfm alueella. Palvelu kattaa joukkoliikenteen, kävelyn, pyöräilyn ja yksityisautoilun rajatuilta osin. Palvelu perustuu Digitransit-palvelualustaan.',
        ],
      },
    ],

    sv: [
      {
        header: 'Om tjänsten',
        paragraphs: [
          'Den här tjänsten erbjuds av Cfm för reseplanering inom Cfm region. Reseplaneraren täcker med vissa begränsningar kollektivtrafik, promenad, cykling samt privatbilism. Tjänsten baserar sig på Digitransit-plattformen.',
        ],
      },
    ],

    en: [
      {
        header: 'About this service',
        paragraphs: [
          'This service is provided by Cfm for route planning in Cfm region. The service covers public transport, walking, cycling, and some private car use. Service is built on Digitransit platform.',
        ],
      },
    ],
  },
});
