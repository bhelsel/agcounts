# shiny countsModuleUI creates expected HTML

    Code
      .testHTML_countsModuleUI("countsModule")
    Output
      <div class="row">
        <div class="col-sm-4">
          <form class="well" role="complementary">
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-epoch-label" for="countsModule-epoch">What epoch level?</label>
              <input class="js-range-slider" id="countsModule-epoch" data-skin="shiny" data-min="1" data-max="60" data-from="30" data-step="1" data-grid="false" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix=" seconds" data-keyboard="true" data-data-type="number"/>
            </div>
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="countsModule-lfe" type="checkbox"/>
                  <span>Add a low frequency extension filter?</span>
                </label>
              </div>
            </div>
            <h5><b>Plot Settings for Calculate Counts</b></h5>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-axisCounts-label" for="countsModule-axisCounts">Counts Axis</label>
              <div>
                <select id="countsModule-axisCounts"><option value="Axis1">Axis1</option>
      <option value="Axis2">Axis2</option>
      <option value="Axis3">Axis3</option>
      <option value="Vector.Magnitude" selected>Vector.Magnitude</option></select>
                <script type="application/json" data-for="countsModule-axisCounts" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="countsModule-excludeZeros" type="checkbox"/>
                  <span>Exclude zeros from the plot?</span>
                </label>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-binwidthCounts-label" for="countsModule-binwidthCounts">Select a frequency polygon binwidth</label>
              <input id="countsModule-binwidthCounts" type="number" class="form-control" value="30" step="10"/>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-countsPlotColor-label" for="countsModule-countsPlotColor">Plot Color (accepts color name or hex code)</label>
              <input id="countsModule-countsPlotColor" type="text" class="form-control" value="#000000"/>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-rangeCounts-label" for="countsModule-rangeCounts">Select a range for the X axis</label>
              <input class="js-range-slider" id="countsModule-rangeCounts" data-skin="shiny" data-type="double" data-min="0" data-max="10000" data-from="0" data-to="2000" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-postfix=" counts" data-keyboard="true" data-drag-interval="true" data-data-type="number"/>
            </div>
          </form>
        </div>
        <div class="col-sm-8" role="main">
          <div class="tabbable">
            <ul class="nav nav-tabs shiny-tab-input" id="countsTabset" data-tabsetid="4785">
              <li class="active">
                <a href="#tab-4785-1" data-toggle="tab" data-bs-toggle="tab" data-value="Visualization">Visualization</a>
              </li>
              <li>
                <a href="#tab-4785-2" data-toggle="tab" data-bs-toggle="tab" data-value="Data">Data</a>
              </li>
            </ul>
            <div class="tab-content" data-tabsetid="4785">
              <div class="tab-pane active" data-value="Visualization" id="tab-4785-1">
                <div class="shiny-plot-output html-fill-item" id="countsModule-countsPlot" style="width:100%;height:400px;"></div>
              </div>
              <div class="tab-pane" data-value="Data" id="tab-4785-2">
                <h5>Total and average accelerometer counts from agcounts</h5>
                <div class="reactable html-widget html-widget-output shiny-report-size html-fill-item-overflow-hidden html-fill-item" data-reactable-output="countsModule-countsReactableTable" id="countsModule-countsReactableTable" style="width:auto;height:auto;"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

