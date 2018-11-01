
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
// qml specific function
function printConfig() {
    print("===== CONFIG ======")
    print(app.bamboo_base_url)
    print(app.bamboocreds)
    print(app.project_key)
    print(app.plan_key)
    print("===================")
}

function publishAppStatus(stat)
{
    print("ERROR")
    app.state = stat.message
    busy_indicator.running = false;
}

function publishUpdateStatus()
{
    startscreen.screentext = "update data";
   // set data to unknown
   //
    for( var i = 0; i < listview.model.count; i++) {
      listview.model.get(i).buildState = "updating";
    }
}


function parseBranchStatusResponse(xmlhttp) {
    var resp = JSON.parse(xmlhttp.responseText);
    if (resp.results.result.length == 0) {
        return;
    }
    appendResultToListView(resp);
    app.state = "ok"
}

function getIndexOfPlanKey(key)
{
  console.log('get index')
    for( var i = 0; i < listview.model.count; i++) {
        if( listview.model.get(i).planKey === key ) {
            console.log('key', key, 'has index' , i);
            return i;
        }
    }
    return undefined
}

function appendResultToListView(arr)
{
    var resultKey = arr.results.result[0].planResultKey.key;
    var planKey = arr.results.result[0].plan.shortKey;
    var list_index = getIndexOfPlanKey(planKey)

    if (list_index === undefined ){
        console.log("add plan: ", planKey)
        listview.model.append(
            {
                name: arr.results.result[0].plan.shortName,
                buildState: arr.results.result[0].state,
                link: arr.results.result[0].link.href,
                resultKey: resultKey,
                planKey: planKey
            })
    } else {
        //update
        console.log("update plan: ", planKey)
        var buildState = listview.model.get(list_index).buildState;

        if (buildState === "BUILDING" || buildState === "QUEUED") {
          console.log("do not override building/queued branches")
        } 
        else {
          listview.model.set(list_index,
              {
                  name: arr.results.result[0].plan.shortName,
                  buildState: arr.results.result[0].state,
                  link: arr.results.result[0].link.href,
                  resultKey: resultKey,
                  planKey: planKey
              })
        }
    }
}

function updateBuildingStatus(e)
{

    var planKey = e.planKey;
    planKey = planKey.split('-').slice(1).join('-');

    console.log("update current build: ", planKey)
    var ind = getIndexOfPlanKey(planKey);

   if (ind !== undefined ) {
      var list_ele = listview.model.get(ind);
      list_ele.buildState = 'BUILDING'
      console.log( list_ele.name)
    }



}

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
// generic functions

function updateData() {

    console.log("update Data");
    busy_indicator.running = true;
    publishUpdateStatus();
    queryMainBranch();
    queryPlanBranchNames();

    queryCurrentBuild();
    busy_indicator.running = false;
}

function queryCurrentBuild()
{
    var url = bamboo_base_url + "/build/admin/ajax/getDashboardSummary.action";
    print(url)

    console.log("...... request build status Status", url);
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {

            print(xmlhttp.responseText);

            var resp = JSON.parse(xmlhttp.responseText);

            var builds = resp.builds;
            var building = [];
            var queued = [];
            for(var i = 0; i < builds.length; i++) {
                var build = builds[i];

                if (build.status === "BUILDING") {
                   building.push(build) 
                }
                else if (build.status === "QUEUED") {
                   queued.push(build) 
                }
            }

            print("---- current building: ", building.length) 
            print("---- current queue: ", queued.length) 

            building.map(updateBuildingStatus);

        } else if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status !== 200) {
            publishAppStatus( { message: "networkerror"} );
        } else {
            // "error receiving data"
        }
    }

    console.log(url);
    xmlhttp.open("GET", url);
    xmlhttp.setRequestHeader("Authorization", "Basic " + Qt.btoa(app.bamboocreds));
    xmlhttp.send();


}


function queryMainBranch() {
    console.log("make request")

    BLogic.printConfig();
    var url = app.bamboo_base_url + '/rest/api/latest/result/' + app.project_key + '-' + app.plan_key + ".json?max-results=1"
    requestBranchStatus(url);
}

function queryPlanBranchStatus(branches) {
    for (var i = 0; i < branches.length; i++) {
        var url = app.bamboo_base_url + '/rest/api/latest/result/' + app.project_key + '-' + branches[i].shortKey + ".json?max-results=1";
        requestBranchStatus(url);
    }
}

function requestBranchStatus(url) {
    console.log("request Branch Status", url);
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
            parseBranchStatusResponse(xmlhttp);
        } else if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status !== 200) {
            publishAppStatus( { message: "networkerror"} );
        } else {
            // "error receiving data"
        }
    }

    console.log(url);
    xmlhttp.open("GET", url);
    xmlhttp.setRequestHeader("Authorization", "Basic " + Qt.btoa(app.bamboocreds));
    xmlhttp.send();
}


function queryPlanBranchNames() {
    console.log('query plan branch names');
    var xmlhttp = new XMLHttpRequest();
    var url = app.bamboo_base_url + '/rest/api/latest/plan/' + app.project_key + '-' + app.plan_key + "/branch.json?start-index=[X]&amp;max-result=[Y]";
    console.log("plan branch name url: " + url)

    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
            var resp = JSON.parse(xmlhttp.responseText);
            var active_branches = resp.branches.branch.filter(function (e) { return e.enabled == true; });
            queryPlanBranchStatus(active_branches);
        } else if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status !== 200) {
            console.log("request finished but not successfull, code: " + xmlhttp.status);

        } else {
            // "error receiving data"
        }
    }

    xmlhttp.ontimeout = function () { console.log("request timeout"); }
    xmlhttp.open("GET", url);
    xmlhttp.setRequestHeader("Authorization", "Basic " + Qt.btoa(app.bamboocreds));
    xmlhttp.send();
}



