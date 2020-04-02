___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Klaviyo / Elevar Monitoring",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "tagName",
    "displayName": "Tag Name",
    "simpleValueType": true,
    "help": "This needs to be equal to the GTM Tag Name. This is needed for monitoring to work correctly."
  },
  {
    "type": "SELECT",
    "name": "type",
    "displayName": "Type",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "track",
        "displayValue": "track"
      },
      {
        "value": "identify",
        "displayValue": "identify"
      },
      {
        "value": "account",
        "displayValue": "account"
      },
      {
        "value": "trackViewedItem",
        "displayValue": "trackViewedItem"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "eventName",
    "displayName": "Event Name",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "type",
        "paramValue": "track",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "PARAM_TABLE",
    "name": "content",
    "displayName": "Additional Data",
    "paramTableColumns": [
      {
        "param": {
          "type": "TEXT",
          "name": "key",
          "displayName": "Key",
          "simpleValueType": true
        },
        "isUnique": true
      },
      {
        "param": {
          "type": "TEXT",
          "name": "value",
          "displayName": "Value",
          "simpleValueType": true
        },
        "isUnique": false
      },
      {
        "param": {
          "type": "TEXT",
          "name": "variableName",
          "displayName": "GTM Variable Name",
          "simpleValueType": true,
          "help": "If you used a GTM variable in the value, then input the GTM name of that variable here. Otherwise leave it empty."
        },
        "isUnique": false
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require("logToConsole");
const createQueue = require("createQueue");

const TAG_INFO = "elevar_gtm_tag_info";
const kDataLayer = "_learnq";
const addTagInformation = createQueue(TAG_INFO);
const pushToKlaviyo = createQueue(kDataLayer);

// Data to be pushed to the klaviyo data layer
const dataArray = [data.type];
const gtmVars = [];

if (data.eventName) {
  dataArray.push(data.eventName);
}

if (data.content) {
  // --- Same as in Facebook and Snapchat pixels ---
  const contentObj = {};

  data.content.forEach(item => {
    contentObj[item.key] = item.value;
    if (item.variableName) gtmVars.push(item.variableName);
  });

  dataArray.push(contentObj);
}

// Always add tag and variable info to window
addTagInformation({
  channel: 'klaviyo',
  tagName: data.tagName,
  eventId: data.gtmEventId,
  variables: gtmVars
});

// Push Data
pushToKlaviyo(dataArray);

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "elevar_gtm_tag_info"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "_learnq"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Track // With Variable Names
  code: |-
    const mockData = {
      tagName: "Klaviyo - Add To Cart",
      type: "track",
      eventName: "Add To Cart",
      content: [
        { key: "currency", value: "EUR", variableName: "dlv - Global - Currency" },
        { key: "price", value: 40.99, variableName: "dlv - Purchase - Total Price" },
      ],
      gtmTagId: 2147483645,
      gtmEventId: 13
    };


    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(window[KLAVIYO]).hasLength(1);
    assertThat(window[KLAVIYO][0]).isEqualTo(['track', 'Add To Cart', { currency: 'EUR', price: 40.99 }]);

    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0].tagName).isEqualTo("Klaviyo - Add To Cart");
    assertThat(window[TAG_INFO][0].channel).isEqualTo('klaviyo');
    assertThat(window[TAG_INFO][0].eventId).isEqualTo(13);
    assertThat(window[TAG_INFO][0].variables).isEqualTo(['dlv - Global - Currency', 'dlv - Purchase - Total Price']);
- name: Track // Without Variable Names
  code: |-
    let mockData = {
      tagName: "Klaviyo - Add To Cart",
      type: "track",
      eventName: "Add To Cart",
      content: [
        { key: "currency", value: "EUR", variableName: "" },
        { key: "price", value: 40.99, variableName: "" },
      ],
      gtmTagId: 2147483645,
      gtmEventId: 13
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(window[KLAVIYO]).hasLength(1);
    assertThat(window[KLAVIYO][0]).isEqualTo(['track', 'Add To Cart', { currency: 'EUR', price: 40.99 }]);

    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0].variables).isEqualTo([]);
- name: Track // With no data
  code: |-
    let mockData = {
      tagName: "Klaviyo - Add To Cart",
      type: "track",
      eventName: "Add To Cart",
      gtmTagId: 2147483645,
      gtmEventId: 13
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(window[KLAVIYO]).hasLength(1);
    assertThat(window[KLAVIYO][0]).isEqualTo(['track', 'Add To Cart']);

    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0].variables).isEqualTo([]);
- name: Track // With no Event Name
  code: |-
    const mockData = {
      tagName: "Klaviyo - Add To Cart",
      type: "track",
      content: [
        { key: "currency", value: "EUR", variableName: "dlv - Global - Currency" },
        { key: "price", value: 40.99, variableName: "dlv - Purchase - Total Price" },
      ],
      gtmTagId: 2147483645,
      gtmEventId: 13
    };


    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(window[KLAVIYO]).hasLength(1);
    assertThat(window[KLAVIYO][0]).isEqualTo(['track', { currency: 'EUR', price: 40.99 }]);

    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0].variables).isEqualTo(['dlv - Global - Currency', 'dlv - Purchase - Total Price']);
- name: Identify // Default
  code: |-
    const mockData = {
      tagName: "Klaviyo - Page View",
      type: "identify",
      content: [
        { key: "$email", value: "thomas.jefferson@example.com", variableName: "dlv - User - Email" },
        { key: "$first_name", value: "Thomas", variableName: "dlv - User - First Name" },
      ],
      gtmTagId: 2147483645,
      gtmEventId: 13
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();
    assertThat(window[KLAVIYO]).hasLength(1);
    assertThat(window[KLAVIYO][0]).isEqualTo(['identify', {
      "$email": "thomas.jefferson@example.com",
      "$first_name": "Thomas"
    }]);

    assertThat(window[TAG_INFO]).hasLength(1);
    assertThat(window[TAG_INFO][0].tagName).isEqualTo("Klaviyo - Page View");
    assertThat(window[TAG_INFO][0].variables).isEqualTo(["dlv - User - Email", "dlv - User - First Name"]);
setup: "const log = require('logToConsole');\n\n// Custom window object used by mock\
  \ functions\nlet window = {};\nconst TAG_INFO = 'elevar_gtm_tag_info';\nconst KLAVIYO\
  \ = '_learnq';\n\n/*\nCreates an array in the window with the key provided and\n\
  returns a function that pushes items to that array.\n*/\nmock('createQueue', (key)\
  \ => {\n  const pushToArray = (arr) => (item) => {\n    arr.push(item);\n  };\n\
  \  \n  if (!window[key]) window[key] = [];\n  return pushToArray(window[key]);\n\
  });"


___NOTES___

Created on 18/02/2020, 18:41:48


