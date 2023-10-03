# shiny rawDataModuleUI creates expected HTML

    Code
      .testHTML_rawDataModuleUI("rawDataModule")
    Output
      <div class="row">
        <div class="col-sm-4">
          <form class="well" role="complementary">
            <div class="form-group shiny-input-container">
              <label class="control-label" id="rawDataModule-gt3xFile-label" for="rawDataModule-gt3xFile">Choose GT3X File</label>
              <div class="input-group">
                <label class="input-group-btn input-group-prepend">
                  <span class="btn btn-default btn-file">
                    Browse...
                    <input id="rawDataModule-gt3xFile" class="shiny-input-file" name="rawDataModule-gt3xFile" type="file" style="position: absolute !important; top: -99999px !important; left: -99999px !important;" accept=".gt3x"/>
                  </span>
                </label>
                <input type="text" class="form-control" placeholder="No file selected" readonly="readonly"/>
              </div>
              <div id="rawDataModule-gt3xFile_progress" class="progress active shiny-file-input-progress">
                <div class="progress-bar"></div>
              </div>
            </div>
            <div id="rawDataModule-parser" class="form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline" role="radiogroup" aria-labelledby="rawDataModule-parser-label">
              <label class="control-label" id="rawDataModule-parser-label" for="rawDataModule-parser">Select your parser</label>
              <div class="shiny-options-group">
                <label class="radio-inline">
                  <input type="radio" name="rawDataModule-parser" value="pygt3x"/>
                  <span>pygt3x</span>
                </label>
                <label class="radio-inline">
                  <input type="radio" name="rawDataModule-parser" value="GGIR"/>
                  <span>GGIR</span>
                </label>
                <label class="radio-inline">
                  <input type="radio" name="rawDataModule-parser" value="read.gt3x"/>
                  <span>read.gt3x</span>
                </label>
                <label class="radio-inline">
                  <input type="radio" name="rawDataModule-parser" value="agcalibrate"/>
                  <span>agcalibrate</span>
                </label>
              </div>
            </div>
            <div id="rawDataModule-dateAccessed" class="shiny-html-output"></div>
            <div id="rawDataModule-timeSlot" class="shiny-html-output"></div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="rawDataModule-axisRaw-label" for="rawDataModule-axisRaw">Raw Axis</label>
              <div>
                <select id="rawDataModule-axisRaw" class="shiny-input-select"><option value="X">X</option>
      <option value="Y" selected>Y</option>
      <option value="Z">Z</option>
      <option value="Vector.Magnitude">Vector.Magnitude</option></select>
                <script type="application/json" data-for="rawDataModule-axisRaw" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div id="rawDataModule-applyRaw" class="shiny-html-output"></div>
            <div id="rawDataModule-applyEpoch" class="shiny-html-output"></div>
            <h5><b>Plot Settings for Raw Data</b></h5>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="rawDataModule-gt3xPlotColor-label" for="rawDataModule-gt3xPlotColor">Plot Color (accepts color name or hex code)</label>
              <input id="rawDataModule-gt3xPlotColor" type="text" class="shiny-input-text form-control" value="#000000"/>
            </div>
            <div id="rawDataModule-rangeXraw" class="shiny-html-output"></div>
            <div id="rawDataModule-rangeYraw" class="shiny-html-output"></div>
          </form>
        </div>
        <div class="col-sm-8" role="main">
          <div class="tabbable">
            <ul class="nav nav-tabs shiny-tab-input" id="rawTabset" data-tabsetid="4785">
              <li class="active">
                <a href="#tab-4785-1" data-toggle="tab" data-bs-toggle="tab" data-value="Visualization">Visualization</a>
              </li>
              <li>
                <a href="#tab-4785-2" data-toggle="tab" data-bs-toggle="tab" data-value="Data">Data</a>
              </li>
              <li>
                <a href="#tab-4785-3" data-toggle="tab" data-bs-toggle="tab" data-value="Notes">Notes</a>
              </li>
            </ul>
            <div class="tab-content" data-tabsetid="4785">
              <div class="tab-pane active" data-value="Visualization" id="tab-4785-1">
                <div class="shiny-plot-output html-fill-item" id="rawDataModule-gt3xPlot" style="width:100%;height:400px;"></div>
              </div>
              <div class="tab-pane" data-value="Data" id="tab-4785-2">
                <h5> Average Raw Acceleration Data by Hour </h5>
                <div class="reactable html-widget html-widget-output shiny-report-size html-fill-item-overflow-hidden html-fill-item" data-reactable-output="rawDataModule-rawReactableTable" id="rawDataModule-rawReactableTable" style="width:auto;height:auto;"></div>
              </div>
              <div class="tab-pane" data-value="Notes" id="tab-4785-3">
                <div id="rawDataModule-sampleFrequency" class="shiny-text-output"></div>
                <div id="rawDataModule-calibrationMethod" class="shiny-html-output"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

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
                  <input id="countsModule-lfe" type="checkbox" class="shiny-input-checkbox"/>
                  <span>Add a low frequency extension filter?</span>
                </label>
              </div>
            </div>
            <h5><b>Plot Settings for Calculate Counts</b></h5>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-axisCounts-label" for="countsModule-axisCounts">Counts Axis</label>
              <div>
                <select id="countsModule-axisCounts" class="shiny-input-select"><option value="Axis1">Axis1</option>
      <option value="Axis2">Axis2</option>
      <option value="Axis3">Axis3</option>
      <option value="Vector.Magnitude" selected>Vector.Magnitude</option></select>
                <script type="application/json" data-for="countsModule-axisCounts" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="countsModule-excludeZeros" type="checkbox" class="shiny-input-checkbox"/>
                  <span>Exclude zeros from the plot?</span>
                </label>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="countsModule-countsPlotColor-label" for="countsModule-countsPlotColor">Plot Color (accepts color name or hex code)</label>
              <input id="countsModule-countsPlotColor" type="text" class="shiny-input-text form-control" value="#000000"/>
            </div>
            <div id="countsModule-rangeCounts" class="shiny-html-output"></div>
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

# shiny compareCountsModuleUI creates expected HTML

    Code
      .testHTML_compareCountsModuleUI("compareCountsModule")
    Output
      <div class="row">
        <div class="col-sm-4">
          <form class="well" role="complementary">
            <div class="form-group shiny-input-container">
              <label class="control-label" id="compareCountsModule-agdFile-label" for="compareCountsModule-agdFile">Choose the Matching AGD File</label>
              <div class="input-group">
                <label class="input-group-btn input-group-prepend">
                  <span class="btn btn-default btn-file">
                    Browse...
                    <input id="compareCountsModule-agdFile" class="shiny-input-file" name="compareCountsModule-agdFile" type="file" style="position: absolute !important; top: -99999px !important; left: -99999px !important;" accept=".agd"/>
                  </span>
                </label>
                <input type="text" class="form-control" placeholder="No file selected" readonly="readonly"/>
              </div>
              <div id="compareCountsModule-agdFile_progress" class="progress active shiny-file-input-progress">
                <div class="progress-bar"></div>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="compareCountsModule-axisCounts2-label" for="compareCountsModule-axisCounts2">Count Axis</label>
              <div>
                <select id="compareCountsModule-axisCounts2" class="shiny-input-select"><option value="Axis1">Axis1</option>
      <option value="Axis2">Axis2</option>
      <option value="Axis3">Axis3</option>
      <option value="Vector.Magnitude" selected>Vector.Magnitude</option></select>
                <script type="application/json" data-for="compareCountsModule-axisCounts2" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="compareCountsModule-agdBlandAltmanPlot" type="checkbox" class="shiny-input-checkbox" checked="checked"/>
                  <span>Bland Altman Plot?</span>
                </label>
              </div>
            </div>
            <div id="compareCountsModule-rangeYBlandAltman" class="shiny-html-output"></div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="compareCountsModule-agdPlotColor-label" for="compareCountsModule-agdPlotColor">Plot Color (accepts color name or hex code)</label>
              <input id="compareCountsModule-agdPlotColor" type="text" class="shiny-input-text form-control" value="#000000"/>
            </div>
          </form>
        </div>
        <div class="col-sm-8" role="main">
          <div class="tabbable">
            <ul class="nav nav-tabs shiny-tab-input" id="comparisonTabset" data-tabsetid="4785">
              <li class="active">
                <a href="#tab-4785-1" data-toggle="tab" data-bs-toggle="tab" data-value="Visualization">Visualization</a>
              </li>
              <li>
                <a href="#tab-4785-2" data-toggle="tab" data-bs-toggle="tab" data-value="Data">Data</a>
              </li>
            </ul>
            <div class="tab-content" data-tabsetid="4785">
              <div class="tab-pane active" data-value="Visualization" id="tab-4785-1">
                <div class="shiny-plot-output html-fill-item" id="compareCountsModule-comparisonPlot" style="width:100%;height:400px;"></div>
              </div>
              <div class="tab-pane" data-value="Data" id="tab-4785-2">
                <h5>Differences between ActiGraph counts and agcounts</h5>
                <div class="reactable html-widget html-widget-output shiny-report-size html-fill-item-overflow-hidden html-fill-item" data-reactable-output="compareCountsModule-comparisonReactableTable" id="compareCountsModule-comparisonReactableTable" style="width:auto;height:auto;"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

