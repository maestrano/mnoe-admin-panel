@App.service 'AddressHelper', () ->
  _self = @

  @countries = [
    {
      label: 'Afghanistan'
      val: 'AF'
      ext: '93'
    }
    {
      label: 'Albania'
      val: 'AL'
      ext: '355'
    }
    {
      label: 'Algeria'
      val: 'DZ'
      ext: '213'
    }
    {
      label: 'American Samoa'
      val: 'AS'
      ext: '1'
    }
    {
      label: 'Andorra'
      val: 'AD'
      ext: '376'
    }
    {
      label: 'Angola'
      val: 'AO'
      ext: '244'
    }
    {
      label: 'Anguilla'
      val: 'AI'
      ext: '1'
    }
    {
      label: 'Antarctica'
      val: 'AQ'
      ext: '672'
    }
    {
      label: 'Antigua and Barbuda'
      val: 'AG'
      ext: '1'
    }
    {
      label: 'Argentina'
      val: 'AR'
      ext: '54'
    }
    {
      label: 'Armenia'
      val: 'AM'
      ext: '374'
    }
    {
      label: 'Aruba'
      val: 'AW'
      ext: '297'
    }
    {
      label: 'Australia'
      val: 'AU'
      ext: '61'
    }
    {
      label: 'Austria'
      val: 'AT'
      ext: '43'
    }
    {
      label: 'Azerbaijan'
      val: 'AZ'
      ext: '994'
    }
    {
      label: 'Bahamas'
      val: 'BS'
      ext: '1'
    }
    {
      label: 'Bahrain'
      val: 'BH'
      ext: '973'
    }
    {
      label: 'Bangladesh'
      val: 'BD'
      ext: '880'
    }
    {
      label: 'Barbados'
      val: 'BB'
      ext: '1'
    }
    {
      label: 'Belarus'
      val: 'BY'
      ext: '375'
    }
    {
      label: 'Belgium'
      val: 'BE'
      ext: '32'
    }
    {
      label: 'Belize'
      val: 'BZ'
      ext: '501'
    }
    {
      label: 'Benin'
      val: 'BJ'
      ext: '229'
    }
    {
      label: 'Bermuda'
      val: 'BM'
      ext: '1'
    }
    {
      label: 'Bhutan'
      val: 'BT'
      ext: '975'
    }
    {
      label: 'Bolivia'
      val: 'BO'
      ext: '591'
    }
    {
      label: 'Bonaire, Sint Eustatius and Saba'
      val: 'BQ'
      ext: '599'
    }
    {
      label: 'Bosnia and Herzegovina'
      val: 'BA'
      ext: '387'
    }
    {
      label: 'Botswana'
      val: 'BW'
      ext: '267'
    }
    {
      label: 'Bouvet Island'
      val: 'BV'
      ext: ''
    }
    {
      label: 'Brazil'
      val: 'BR'
      ext: '55'
    }
    {
      label: 'British Indian Ocean Territory'
      val: 'IO'
      ext: '246'
    }
    {
      label: 'Brunei Darussalam'
      val: 'BN'
      ext: '673'
    }
    {
      label: 'Bulgaria'
      val: 'BG'
      ext: '359'
    }
    {
      label: 'Burkina Faso'
      val: 'BF'
      ext: '226'
    }
    {
      label: 'Burundi'
      val: 'BI'
      ext: '257'
    }
    {
      label: 'Cambodia'
      val: 'KH'
      ext: '855'
    }
    {
      label: 'Cameroon'
      val: 'CM'
      ext: '237'
    }
    {
      label: 'Canada'
      val: 'CA'
      ext: '1'
    }
    {
      label: 'Cape Verde'
      val: 'CV'
      ext: '238'
    }
    {
      label: 'Cayman Islands'
      val: 'KY'
      ext: '1'
    }
    {
      label: 'Central African Republic'
      val: 'CF'
      ext: '236'
    }
    {
      label: 'Chad'
      val: 'TD'
      ext: '235'
    }
    {
      label: 'Chile'
      val: 'CL'
      ext: '56'
    }
    {
      label: 'China'
      val: 'CN'
      ext: '86'
    }
    {
      label: 'Christmas Island'
      val: 'CX'
      ext: '61'
    }
    {
      label: 'Cocos (Keeling) Islands'
      val: 'CC'
      ext: '61'
    }
    {
      label: 'Colombia'
      val: 'CO'
      ext: '57'
    }
    {
      label: 'Comoros'
      val: 'KM'
      ext: '269'
    }
    {
      label: 'Congo'
      val: 'CG'
      ext: '242'
    }
    {
      label: 'Congo, The Democratic Republic Of The'
      val: 'CD'
      ext: '243'
    }
    {
      label: 'Cook Islands'
      val: 'CK'
      ext: '682'
    }
    {
      label: 'Costa Rica'
      val: 'CR'
      ext: '506'
    }
    {
      label: 'Croatia'
      val: 'HR'
      ext: '385'
    }
    {
      label: 'Cuba'
      val: 'CU'
      ext: '53'
    }
    {
      label: 'Curaçao'
      val: 'CW'
      ext: '599'
    }
    {
      label: 'Cyprus'
      val: 'CY'
      ext: '357'
    }
    {
      label: 'Czech Republic'
      val: 'CZ'
      ext: '420'
    }
    {
      label: 'Côte D\'Ivoire'
      val: 'CI'
      ext: '225'
    }
    {
      label: 'Denmark'
      val: 'DK'
      ext: '45'
    }
    {
      label: 'Djibouti'
      val: 'DJ'
      ext: '253'
    }
    {
      label: 'Dominica'
      val: 'DM'
      ext: '1'
    }
    {
      label: 'Dominican Republic'
      val: 'DO'
      ext: '1'
    }
    {
      label: 'Ecuador'
      val: 'EC'
      ext: '593'
    }
    {
      label: 'Egypt'
      val: 'EG'
      ext: '20'
    }
    {
      label: 'El Salvador'
      val: 'SV'
      ext: '503'
    }
    {
      label: 'Equatorial Guinea'
      val: 'GQ'
      ext: '240'
    }
    {
      label: 'Eritrea'
      val: 'ER'
      ext: '291'
    }
    {
      label: 'Estonia'
      val: 'EE'
      ext: '372'
    }
    {
      label: 'Ethiopia'
      val: 'ET'
      ext: '251'
    }
    {
      label: 'Falkland Islands (Malvinas)'
      val: 'FK'
      ext: '500'
    }
    {
      label: 'Faroe Islands'
      val: 'FO'
      ext: '298'
    }
    {
      label: 'Fiji'
      val: 'FJ'
      ext: '679'
    }
    {
      label: 'Finland'
      val: 'FI'
      ext: '358'
    }
    {
      label: 'France'
      val: 'FR'
      ext: '33'
    }
    {
      label: 'French Guiana'
      val: 'GF'
      ext: '594'
    }
    {
      label: 'French Polynesia'
      val: 'PF'
      ext: '689'
    }
    {
      label: 'French Southern Territories'
      val: 'TF'
      ext: ''
    }
    {
      label: 'Gabon'
      val: 'GA'
      ext: '241'
    }
    {
      label: 'Gambia'
      val: 'GM'
      ext: '220'
    }
    {
      label: 'Georgia'
      val: 'GE'
      ext: '995'
    }
    {
      label: 'Germany'
      val: 'DE'
      ext: '49'
    }
    {
      label: 'Ghana'
      val: 'GH'
      ext: '233'
    }
    {
      label: 'Gibraltar'
      val: 'GI'
      ext: '350'
    }
    {
      label: 'Greece'
      val: 'GR'
      ext: '30'
    }
    {
      label: 'Greenland'
      val: 'GL'
      ext: '299'
    }
    {
      label: 'Grenada'
      val: 'GD'
      ext: '1'
    }
    {
      label: 'Guadeloupe'
      val: 'GP'
      ext: '590'
    }
    {
      label: 'Guam'
      val: 'GU'
      ext: '1'
    }
    {
      label: 'Guatemala'
      val: 'GT'
      ext: '502'
    }
    {
      label: 'Guernsey'
      val: 'GG'
      ext: '44'
    }
    {
      label: 'Guinea'
      val: 'GN'
      ext: '224'
    }
    {
      label: 'Guinea-Bissau'
      val: 'GW'
      ext: '245'
    }
    {
      label: 'Guyana'
      val: 'GY'
      ext: '592'
    }
    {
      label: 'Haiti'
      val: 'HT'
      ext: '509'
    }
    {
      label: 'Heard and McDonald Islands'
      val: 'HM'
      ext: ''
    }
    {
      label: 'Holy See (Vatican City State)'
      val: 'VA'
      ext: '39'
    }
    {
      label: 'Honduras'
      val: 'HN'
      ext: '504'
    }
    {
      label: 'Hong Kong'
      val: 'HK'
      ext: '852'
    }
    {
      label: 'Hungary'
      val: 'HU'
      ext: '36'
    }
    {
      label: 'Iceland'
      val: 'IS'
      ext: '354'
    }
    {
      label: 'India'
      val: 'IN'
      ext: '91'
    }
    {
      label: 'Indonesia'
      val: 'ID'
      ext: '62'
    }
    {
      label: 'Iran, Islamic Republic Of'
      val: 'IR'
      ext: '98'
    }
    {
      label: 'Iraq'
      val: 'IQ'
      ext: '964'
    }
    {
      label: 'Ireland'
      val: 'IE'
      ext: '353'
    }
    {
      label: 'Isle of Man'
      val: 'IM'
      ext: '44'
    }
    {
      label: 'Israel'
      val: 'IL'
      ext: '972'
    }
    {
      label: 'Italy'
      val: 'IT'
      ext: '39'
    }
    {
      label: 'Jamaica'
      val: 'JM'
      ext: '1'
    }
    {
      label: 'Japan'
      val: 'JP'
      ext: '81'
    }
    {
      label: 'Jersey'
      val: 'JE'
      ext: '44'
    }
    {
      label: 'Jordan'
      val: 'JO'
      ext: '962'
    }
    {
      label: 'Kazakhstan'
      val: 'KZ'
      ext: '7'
    }
    {
      label: 'Kenya'
      val: 'KE'
      ext: '254'
    }
    {
      label: 'Kiribati'
      val: 'KI'
      ext: '686'
    }
    {
      label: 'Korea, Democratic People\'s Republic Of'
      val: 'KP'
      ext: '850'
    }
    {
      label: 'Korea, Republic of'
      val: 'KR'
      ext: '82'
    }
    {
      label: 'Kuwait'
      val: 'KW'
      ext: '965'
    }
    {
      label: 'Kyrgyzstan'
      val: 'KG'
      ext: '996'
    }
    {
      label: 'Lao People\'s Democratic Republic'
      val: 'LA'
      ext: '856'
    }
    {
      label: 'Latvia'
      val: 'LV'
      ext: '371'
    }
    {
      label: 'Lebanon'
      val: 'LB'
      ext: '961'
    }
    {
      label: 'Lesotho'
      val: 'LS'
      ext: '266'
    }
    {
      label: 'Liberia'
      val: 'LR'
      ext: '231'
    }
    {
      label: 'Libya'
      val: 'LY'
      ext: '218'
    }
    {
      label: 'Liechtenstein'
      val: 'LI'
      ext: '423'
    }
    {
      label: 'Lithuania'
      val: 'LT'
      ext: '370'
    }
    {
      label: 'Luxembourg'
      val: 'LU'
      ext: '352'
    }
    {
      label: 'Macao'
      val: 'MO'
      ext: '853'
    }
    {
      label: 'Macedonia, the Former Yugoslav Republic Of'
      val: 'MK'
      ext: '389'
    }
    {
      label: 'Madagascar'
      val: 'MG'
      ext: '261'
    }
    {
      label: 'Malawi'
      val: 'MW'
      ext: '265'
    }
    {
      label: 'Malaysia'
      val: 'MY'
      ext: '60'
    }
    {
      label: 'Maldives'
      val: 'MV'
      ext: '960'
    }
    {
      label: 'Mali'
      val: 'ML'
      ext: '223'
    }
    {
      label: 'Malta'
      val: 'MT'
      ext: '356'
    }
    {
      label: 'Marshall Islands'
      val: 'MH'
      ext: '692'
    }
    {
      label: 'Martinique'
      val: 'MQ'
      ext: '596'
    }
    {
      label: 'Mauritania'
      val: 'MR'
      ext: '222'
    }
    {
      label: 'Mauritius'
      val: 'MU'
      ext: '230'
    }
    {
      label: 'Mayotte'
      val: 'YT'
      ext: '262'
    }
    {
      label: 'Mexico'
      val: 'MX'
      ext: '52'
    }
    {
      label: 'Micronesia, Federated States Of'
      val: 'FM'
      ext: '691'
    }
    {
      label: 'Moldova, Republic of'
      val: 'MD'
      ext: '373'
    }
    {
      label: 'Monaco'
      val: 'MC'
      ext: '377'
    }
    {
      label: 'Mongolia'
      val: 'MN'
      ext: '976'
    }
    {
      label: 'Montenegro'
      val: 'ME'
      ext: '382'
    }
    {
      label: 'Montserrat'
      val: 'MS'
      ext: '1'
    }
    {
      label: 'Morocco'
      val: 'MA'
      ext: '212'
    }
    {
      label: 'Mozambique'
      val: 'MZ'
      ext: '258'
    }
    {
      label: 'Myanmar'
      val: 'MM'
      ext: '95'
    }
    {
      label: 'Namibia'
      val: 'NA'
      ext: '264'
    }
    {
      label: 'Nauru'
      val: 'NR'
      ext: '674'
    }
    {
      label: 'Nepal'
      val: 'NP'
      ext: '977'
    }
    {
      label: 'Netherlands'
      val: 'NL'
      ext: '31'
    }
    {
      label: 'Netherlands Antilles'
      val: 'AN'
      ext: '599'
    }
    {
      label: 'New Caledonia'
      val: 'NC'
      ext: '687'
    }
    {
      label: 'New Zealand'
      val: 'NZ'
      ext: '64'
    }
    {
      label: 'Nicaragua'
      val: 'NI'
      ext: '505'
    }
    {
      label: 'Niger'
      val: 'NE'
      ext: '227'
    }
    {
      label: 'Nigeria'
      val: 'NG'
      ext: '234'
    }
    {
      label: 'Niue'
      val: 'NU'
      ext: '683'
    }
    {
      label: 'Norfolk Island'
      val: 'NF'
      ext: '672'
    }
    {
      label: 'Northern Mariana Islands'
      val: 'MP'
      ext: '1'
    }
    {
      label: 'Norway'
      val: 'NO'
      ext: '47'
    }
    {
      label: 'Oman'
      val: 'OM'
      ext: '968'
    }
    {
      label: 'Pakistan'
      val: 'PK'
      ext: '92'
    }
    {
      label: 'Palau'
      val: 'PW'
      ext: '680'
    }
    {
      label: 'Palestine, State of'
      val: 'PS'
      ext: '970'
    }
    {
      label: 'Panama'
      val: 'PA'
      ext: '507'
    }
    {
      label: 'Papua New Guinea'
      val: 'PG'
      ext: '675'
    }
    {
      label: 'Paraguay'
      val: 'PY'
      ext: '595'
    }
    {
      label: 'Peru'
      val: 'PE'
      ext: '51'
    }
    {
      label: 'Philippines'
      val: 'PH'
      ext: '63'
    }
    {
      label: 'Pitcairn'
      val: 'PN'
      ext: ''
    }
    {
      label: 'Poland'
      val: 'PL'
      ext: '48'
    }
    {
      label: 'Portugal'
      val: 'PT'
      ext: '351'
    }
    {
      label: 'Puerto Rico'
      val: 'PR'
      ext: '1'
    }
    {
      label: 'Qatar'
      val: 'QA'
      ext: '974'
    }
    {
      label: 'Romania'
      val: 'RO'
      ext: '40'
    }
    {
      label: 'Russian Federation'
      val: 'RU'
      ext: '7'
    }
    {
      label: 'Rwanda'
      val: 'RW'
      ext: '250'
    }
    {
      label: 'Réunion'
      val: 'RE'
      ext: '262'
    }
    {
      label: 'Saint Barthélemy'
      val: 'BL'
      ext: '590'
    }
    {
      label: 'Saint Helena'
      val: 'SH'
      ext: '290'
    }
    {
      label: 'Saint Kitts And Nevis'
      val: 'KN'
      ext: '1'
    }
    {
      label: 'Saint Lucia'
      val: 'LC'
      ext: '1'
    }
    {
      label: 'Saint Martin'
      val: 'MF'
      ext: '590'
    }
    {
      label: 'Saint Pierre And Miquelon'
      val: 'PM'
      ext: '508'
    }
    {
      label: 'Saint Vincent And The Grenedines'
      val: 'VC'
      ext: '1'
    }
    {
      label: 'Samoa'
      val: 'WS'
      ext: '685'
    }
    {
      label: 'San Marino'
      val: 'SM'
      ext: '378'
    }
    {
      label: 'Sao Tome and Principe'
      val: 'ST'
      ext: '239'
    }
    {
      label: 'Saudi Arabia'
      val: 'SA'
      ext: '966'
    }
    {
      label: 'Senegal'
      val: 'SN'
      ext: '221'
    }
    {
      label: 'Serbia'
      val: 'RS'
      ext: '381'
    }
    {
      label: 'Seychelles'
      val: 'SC'
      ext: '248'
    }
    {
      label: 'Sierra Leone'
      val: 'SL'
      ext: '232'
    }
    {
      label: 'Singapore'
      val: 'SG'
      ext: '65'
    }
    {
      label: 'Sint Maarten'
      val: 'SX'
      ext: '1'
    }
    {
      label: 'Slovakia'
      val: 'SK'
      ext: '421'
    }
    {
      label: 'Slovenia'
      val: 'SI'
      ext: '386'
    }
    {
      label: 'Solomon Islands'
      val: 'SB'
      ext: '677'
    }
    {
      label: 'Somalia'
      val: 'SO'
      ext: '252'
    }
    {
      label: 'South Africa'
      val: 'ZA'
      ext: '27'
    }
    {
      label: 'South Georgia and the South Sandwich Islands'
      val: 'GS'
      ext: '500'
    }
    {
      label: 'South Sudan'
      val: 'SS'
      ext: '211'
    }
    {
      label: 'Spain'
      val: 'ES'
      ext: '34'
    }
    {
      label: 'Sri Lanka'
      val: 'LK'
      ext: '94'
    }
    {
      label: 'Sudan'
      val: 'SD'
      ext: '249'
    }
    {
      label: 'Suriname'
      val: 'SR'
      ext: '597'
    }
    {
      label: 'Svalbard And Jan Mayen'
      val: 'SJ'
      ext: '47'
    }
    {
      label: 'Swaziland'
      val: 'SZ'
      ext: '268'
    }
    {
      label: 'Sweden'
      val: 'SE'
      ext: '46'
    }
    {
      label: 'Switzerland'
      val: 'CH'
      ext: '41'
    }
    {
      label: 'Syrian Arab Republic'
      val: 'SY'
      ext: '963'
    }
    {
      label: 'Taiwan, Republic Of China'
      val: 'TW'
      ext: '886'
    }
    {
      label: 'Tajikistan'
      val: 'TJ'
      ext: '992'
    }
    {
      label: 'Tanzania, United Republic of'
      val: 'TZ'
      ext: '255'
    }
    {
      label: 'Thailand'
      val: 'TH'
      ext: '66'
    }
    {
      label: 'Timor-Leste'
      val: 'TL'
      ext: '670'
    }
    {
      label: 'Togo'
      val: 'TG'
      ext: '228'
    }
    {
      label: 'Tokelau'
      val: 'TK'
      ext: '690'
    }
    {
      label: 'Tonga'
      val: 'TO'
      ext: '676'
    }
    {
      label: 'Trinidad and Tobago'
      val: 'TT'
      ext: '1'
    }
    {
      label: 'Tunisia'
      val: 'TN'
      ext: '216'
    }
    {
      label: 'Turkey'
      val: 'TR'
      ext: '90'
    }
    {
      label: 'Turkmenistan'
      val: 'TM'
      ext: '993'
    }
    {
      label: 'Turks and Caicos Islands'
      val: 'TC'
      ext: '1'
    }
    {
      label: 'Tuvalu'
      val: 'TV'
      ext: '688'
    }
    {
      label: 'Uganda'
      val: 'UG'
      ext: '256'
    }
    {
      label: 'Ukraine'
      val: 'UA'
      ext: '380'
    }
    {
      label: 'United Arab Emirates'
      val: 'AE'
      ext: '971'
    }
    {
      label: 'United Kingdom'
      val: 'GB'
      ext: '44'
    }
    {
      label: 'United States'
      val: 'US'
      ext: '1'
    }
    {
      label: 'United States Minor Outlying Islands'
      val: 'UM'
      ext: ''
    }
    {
      label: 'Uruguay'
      val: 'UY'
      ext: '598'
    }
    {
      label: 'Uzbekistan'
      val: 'UZ'
      ext: '998'
    }
    {
      label: 'Vanuatu'
      val: 'VU'
      ext: '678'
    }
    {
      label: 'Venezuela, Bolivarian Republic of'
      val: 'VE'
      ext: '58'
    }
    {
      label: 'Vietnam'
      val: 'VN'
      ext: '84'
    }
    {
      label: 'Virgin Islands, British'
      val: 'VG'
      ext: '1'
    }
    {
      label: 'Virgin Islands, U.S.'
      val: 'VI'
      ext: '1'
    }
    {
      label: 'Wallis and Futuna'
      val: 'WF'
      ext: '681'
    }
    {
      label: 'Western Sahara'
      val: 'EH'
      ext: '212'
    }
    {
      label: 'Yemen'
      val: 'YE'
      ext: '967'
    }
    {
      label: 'Zambia'
      val: 'ZM'
      ext: '260'
    }
    {
      label: 'Zimbabwe'
      val: 'ZW'
      ext: '263'
    }
    {
      label: 'Åland Islands'
      val: 'AX'
      ext: '358'
    }
  ]

  @countryCodes = [
    [
      'AD'
      '(AD) +376'
    ]
    [
      'AE'
      '(AE) +971'
    ]
    [
      'AF'
      '(AF) +93'
    ]
    [
      'AG'
      '(AG) +1'
    ]
    [
      'AI'
      '(AI) +1'
    ]
    [
      'AL'
      '(AL) +355'
    ]
    [
      'AM'
      '(AM) +374'
    ]
    [
      'AN'
      '(AN) +599'
    ]
    [
      'AO'
      '(AO) +244'
    ]
    [
      'AQ'
      '(AQ) +672'
    ]
    [
      'AR'
      '(AR) +54'
    ]
    [
      'AS'
      '(AS) +1'
    ]
    [
      'AT'
      '(AT) +43'
    ]
    [
      'AU'
      '(AU) +61'
    ]
    [
      'AW'
      '(AW) +297'
    ]
    [
      'AX'
      '(AX) +358'
    ]
    [
      'AZ'
      '(AZ) +994'
    ]
    [
      'BA'
      '(BA) +387'
    ]
    [
      'BB'
      '(BB) +1'
    ]
    [
      'BD'
      '(BD) +880'
    ]
    [
      'BE'
      '(BE) +32'
    ]
    [
      'BF'
      '(BF) +226'
    ]
    [
      'BG'
      '(BG) +359'
    ]
    [
      'BH'
      '(BH) +973'
    ]
    [
      'BI'
      '(BI) +257'
    ]
    [
      'BJ'
      '(BJ) +229'
    ]
    [
      'BL'
      '(BL) +590'
    ]
    [
      'BM'
      '(BM) +1'
    ]
    [
      'BN'
      '(BN) +673'
    ]
    [
      'BO'
      '(BO) +591'
    ]
    [
      'BQ'
      '(BQ) +599'
    ]
    [
      'BR'
      '(BR) +55'
    ]
    [
      'BS'
      '(BS) +1'
    ]
    [
      'BT'
      '(BT) +975'
    ]
    [
      'BV'
      '(BV) +'
    ]
    [
      'BW'
      '(BW) +267'
    ]
    [
      'BY'
      '(BY) +375'
    ]
    [
      'BZ'
      '(BZ) +501'
    ]
    [
      'CA'
      '(CA) +1'
    ]
    [
      'CC'
      '(CC) +61'
    ]
    [
      'CD'
      '(CD) +243'
    ]
    [
      'CF'
      '(CF) +236'
    ]
    [
      'CG'
      '(CG) +242'
    ]
    [
      'CH'
      '(CH) +41'
    ]
    [
      'CI'
      '(CI) +225'
    ]
    [
      'CK'
      '(CK) +682'
    ]
    [
      'CL'
      '(CL) +56'
    ]
    [
      'CM'
      '(CM) +237'
    ]
    [
      'CN'
      '(CN) +86'
    ]
    [
      'CO'
      '(CO) +57'
    ]
    [
      'CR'
      '(CR) +506'
    ]
    [
      'CU'
      '(CU) +53'
    ]
    [
      'CV'
      '(CV) +238'
    ]
    [
      'CW'
      '(CW) +599'
    ]
    [
      'CX'
      '(CX) +61'
    ]
    [
      'CY'
      '(CY) +357'
    ]
    [
      'CZ'
      '(CZ) +420'
    ]
    [
      'DE'
      '(DE) +49'
    ]
    [
      'DJ'
      '(DJ) +253'
    ]
    [
      'DK'
      '(DK) +45'
    ]
    [
      'DM'
      '(DM) +1'
    ]
    [
      'DO'
      '(DO) +1'
    ]
    [
      'DZ'
      '(DZ) +213'
    ]
    [
      'EC'
      '(EC) +593'
    ]
    [
      'EE'
      '(EE) +372'
    ]
    [
      'EG'
      '(EG) +20'
    ]
    [
      'EH'
      '(EH) +212'
    ]
    [
      'ER'
      '(ER) +291'
    ]
    [
      'ES'
      '(ES) +34'
    ]
    [
      'ET'
      '(ET) +251'
    ]
    [
      'FI'
      '(FI) +358'
    ]
    [
      'FJ'
      '(FJ) +679'
    ]
    [
      'FK'
      '(FK) +500'
    ]
    [
      'FM'
      '(FM) +691'
    ]
    [
      'FO'
      '(FO) +298'
    ]
    [
      'FR'
      '(FR) +33'
    ]
    [
      'GA'
      '(GA) +241'
    ]
    [
      'GB'
      '(GB) +44'
    ]
    [
      'GD'
      '(GD) +1'
    ]
    [
      'GE'
      '(GE) +995'
    ]
    [
      'GF'
      '(GF) +594'
    ]
    [
      'GG'
      '(GG) +44'
    ]
    [
      'GH'
      '(GH) +233'
    ]
    [
      'GI'
      '(GI) +350'
    ]
    [
      'GL'
      '(GL) +299'
    ]
    [
      'GM'
      '(GM) +220'
    ]
    [
      'GN'
      '(GN) +224'
    ]
    [
      'GP'
      '(GP) +590'
    ]
    [
      'GQ'
      '(GQ) +240'
    ]
    [
      'GR'
      '(GR) +30'
    ]
    [
      'GS'
      '(GS) +500'
    ]
    [
      'GT'
      '(GT) +502'
    ]
    [
      'GU'
      '(GU) +1'
    ]
    [
      'GW'
      '(GW) +245'
    ]
    [
      'GY'
      '(GY) +592'
    ]
    [
      'HK'
      '(HK) +852'
    ]
    [
      'HM'
      '(HM) +'
    ]
    [
      'HN'
      '(HN) +504'
    ]
    [
      'HR'
      '(HR) +385'
    ]
    [
      'HT'
      '(HT) +509'
    ]
    [
      'HU'
      '(HU) +36'
    ]
    [
      'ID'
      '(ID) +62'
    ]
    [
      'IE'
      '(IE) +353'
    ]
    [
      'IL'
      '(IL) +972'
    ]
    [
      'IM'
      '(IM) +44'
    ]
    [
      'IN'
      '(IN) +91'
    ]
    [
      'IO'
      '(IO) +246'
    ]
    [
      'IQ'
      '(IQ) +964'
    ]
    [
      'IR'
      '(IR) +98'
    ]
    [
      'IS'
      '(IS) +354'
    ]
    [
      'IT'
      '(IT) +39'
    ]
    [
      'JE'
      '(JE) +44'
    ]
    [
      'JM'
      '(JM) +1'
    ]
    [
      'JO'
      '(JO) +962'
    ]
    [
      'JP'
      '(JP) +81'
    ]
    [
      'KE'
      '(KE) +254'
    ]
    [
      'KG'
      '(KG) +996'
    ]
    [
      'KH'
      '(KH) +855'
    ]
    [
      'KI'
      '(KI) +686'
    ]
    [
      'KM'
      '(KM) +269'
    ]
    [
      'KN'
      '(KN) +1'
    ]
    [
      'KP'
      '(KP) +850'
    ]
    [
      'KR'
      '(KR) +82'
    ]
    [
      'KW'
      '(KW) +965'
    ]
    [
      'KY'
      '(KY) +1'
    ]
    [
      'KZ'
      '(KZ) +7'
    ]
    [
      'LA'
      '(LA) +856'
    ]
    [
      'LB'
      '(LB) +961'
    ]
    [
      'LC'
      '(LC) +1'
    ]
    [
      'LI'
      '(LI) +423'
    ]
    [
      'LK'
      '(LK) +94'
    ]
    [
      'LR'
      '(LR) +231'
    ]
    [
      'LS'
      '(LS) +266'
    ]
    [
      'LT'
      '(LT) +370'
    ]
    [
      'LU'
      '(LU) +352'
    ]
    [
      'LV'
      '(LV) +371'
    ]
    [
      'LY'
      '(LY) +218'
    ]
    [
      'MA'
      '(MA) +212'
    ]
    [
      'MC'
      '(MC) +377'
    ]
    [
      'MD'
      '(MD) +373'
    ]
    [
      'ME'
      '(ME) +382'
    ]
    [
      'MF'
      '(MF) +590'
    ]
    [
      'MG'
      '(MG) +261'
    ]
    [
      'MH'
      '(MH) +692'
    ]
    [
      'MK'
      '(MK) +389'
    ]
    [
      'ML'
      '(ML) +223'
    ]
    [
      'MM'
      '(MM) +95'
    ]
    [
      'MN'
      '(MN) +976'
    ]
    [
      'MO'
      '(MO) +853'
    ]
    [
      'MP'
      '(MP) +1'
    ]
    [
      'MQ'
      '(MQ) +596'
    ]
    [
      'MR'
      '(MR) +222'
    ]
    [
      'MS'
      '(MS) +1'
    ]
    [
      'MT'
      '(MT) +356'
    ]
    [
      'MU'
      '(MU) +230'
    ]
    [
      'MV'
      '(MV) +960'
    ]
    [
      'MW'
      '(MW) +265'
    ]
    [
      'MX'
      '(MX) +52'
    ]
    [
      'MY'
      '(MY) +60'
    ]
    [
      'MZ'
      '(MZ) +258'
    ]
    [
      'NA'
      '(NA) +264'
    ]
    [
      'NC'
      '(NC) +687'
    ]
    [
      'NE'
      '(NE) +227'
    ]
    [
      'NF'
      '(NF) +672'
    ]
    [
      'NG'
      '(NG) +234'
    ]
    [
      'NI'
      '(NI) +505'
    ]
    [
      'NL'
      '(NL) +31'
    ]
    [
      'NO'
      '(NO) +47'
    ]
    [
      'NP'
      '(NP) +977'
    ]
    [
      'NR'
      '(NR) +674'
    ]
    [
      'NU'
      '(NU) +683'
    ]
    [
      'NZ'
      '(NZ) +64'
    ]
    [
      'OM'
      '(OM) +968'
    ]
    [
      'PA'
      '(PA) +507'
    ]
    [
      'PE'
      '(PE) +51'
    ]
    [
      'PF'
      '(PF) +689'
    ]
    [
      'PG'
      '(PG) +675'
    ]
    [
      'PH'
      '(PH) +63'
    ]
    [
      'PK'
      '(PK) +92'
    ]
    [
      'PL'
      '(PL) +48'
    ]
    [
      'PM'
      '(PM) +508'
    ]
    [
      'PN'
      '(PN) +'
    ]
    [
      'PR'
      '(PR) +1'
    ]
    [
      'PS'
      '(PS) +970'
    ]
    [
      'PT'
      '(PT) +351'
    ]
    [
      'PW'
      '(PW) +680'
    ]
    [
      'PY'
      '(PY) +595'
    ]
    [
      'QA'
      '(QA) +974'
    ]
    [
      'RE'
      '(RE) +262'
    ]
    [
      'RO'
      '(RO) +40'
    ]
    [
      'RS'
      '(RS) +381'
    ]
    [
      'RU'
      '(RU) +7'
    ]
    [
      'RW'
      '(RW) +250'
    ]
    [
      'SA'
      '(SA) +966'
    ]
    [
      'SB'
      '(SB) +677'
    ]
    [
      'SC'
      '(SC) +248'
    ]
    [
      'SD'
      '(SD) +249'
    ]
    [
      'SE'
      '(SE) +46'
    ]
    [
      'SG'
      '(SG) +65'
    ]
    [
      'SH'
      '(SH) +290'
    ]
    [
      'SI'
      '(SI) +386'
    ]
    [
      'SJ'
      '(SJ) +47'
    ]
    [
      'SK'
      '(SK) +421'
    ]
    [
      'SL'
      '(SL) +232'
    ]
    [
      'SM'
      '(SM) +378'
    ]
    [
      'SN'
      '(SN) +221'
    ]
    [
      'SO'
      '(SO) +252'
    ]
    [
      'SR'
      '(SR) +597'
    ]
    [
      'SS'
      '(SS) +211'
    ]
    [
      'ST'
      '(ST) +239'
    ]
    [
      'SV'
      '(SV) +503'
    ]
    [
      'SX'
      '(SX) +1'
    ]
    [
      'SY'
      '(SY) +963'
    ]
    [
      'SZ'
      '(SZ) +268'
    ]
    [
      'TC'
      '(TC) +1'
    ]
    [
      'TD'
      '(TD) +235'
    ]
    [
      'TF'
      '(TF) +'
    ]
    [
      'TG'
      '(TG) +228'
    ]
    [
      'TH'
      '(TH) +66'
    ]
    [
      'TJ'
      '(TJ) +992'
    ]
    [
      'TK'
      '(TK) +690'
    ]
    [
      'TL'
      '(TL) +670'
    ]
    [
      'TM'
      '(TM) +993'
    ]
    [
      'TN'
      '(TN) +216'
    ]
    [
      'TO'
      '(TO) +676'
    ]
    [
      'TR'
      '(TR) +90'
    ]
    [
      'TT'
      '(TT) +1'
    ]
    [
      'TV'
      '(TV) +688'
    ]
    [
      'TW'
      '(TW) +886'
    ]
    [
      'TZ'
      '(TZ) +255'
    ]
    [
      'UA'
      '(UA) +380'
    ]
    [
      'UG'
      '(UG) +256'
    ]
    [
      'UM'
      '(UM) +'
    ]
    [
      'US'
      '(US) +1'
    ]
    [
      'UY'
      '(UY) +598'
    ]
    [
      'UZ'
      '(UZ) +998'
    ]
    [
      'VA'
      '(VA) +39'
    ]
    [
      'VC'
      '(VC) +1'
    ]
    [
      'VE'
      '(VE) +58'
    ]
    [
      'VG'
      '(VG) +1'
    ]
    [
      'VI'
      '(VI) +1'
    ]
    [
      'VN'
      '(VN) +84'
    ]
    [
      'VU'
      '(VU) +678'
    ]
    [
      'WF'
      '(WF) +681'
    ]
    [
      'WS'
      '(WS) +685'
    ]
    [
      'YE'
      '(YE) +967'
    ]
    [
      'YT'
      '(YT) +262'
    ]
    [
      'ZA'
      '(ZA) +27'
    ]
    [
      'ZM'
      '(ZM) +260'
    ]
    [
      'ZW'
      '(ZW) +263'
    ]
  ]

  return
