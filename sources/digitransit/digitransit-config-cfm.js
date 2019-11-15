/* eslint-disable */
import configMerger from '../util/configMerger';

const CONFIG = 'cfm';
const APP_TITLE = 'Digitransit';
const APP_DESCRIPTION = 'Digitransit';

const MAP_URL =
  process.env.MAP_URL || 'https://maps.wikimedia.org/osm-intl/';

const walttiConfig = require('./waltti').default;

const minLat = 51.4807;
const maxLat = 52.4711;
const minLon = 6.3863;
const maxLon = 8.3180;

export default configMerger(walttiConfig, {
  CONFIG,

  URL: {
    MAP: {
      default: MAP_URL,
    },
  },

  appBarLink: { name: 'Cfm', href: 'https://codeformuenster.org/' },

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

  feedIds: ['STWMS'],

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
    // FIXME
    // address: 'Domplatz',
    address: 'Cfm',
    lat: 0.5 * (minLat + maxLat),
    lon: 0.5 * (minLon + maxLon),
  },

  defaultOrigins: [
    // FIXME lat/lon
    { icon: 'icon-icon_star', label: 'Bült', lat: 51.964022, lon: 7.630633 },
    { icon: 'icon-icon_rail', label: 'Hauptbahnhof', lat: 51.957418, lon: 7.635712 },
    // { icon: 'icon-icon_tram', label: 'Uni Süd', lat: 48.42153, lon: 9.95652 },
  ],

  footer: {
    content: [
      { label: `Cfm ${walttiConfig.YEAR}` },
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
