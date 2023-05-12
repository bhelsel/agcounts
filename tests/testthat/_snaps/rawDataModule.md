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
                    <input id="rawDataModule-gt3xFile" name="rawDataModule-gt3xFile" type="file" style="position: absolute !important; top: -99999px !important; left: -99999px !important;" accept=".gt3x"/>
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
                  <input type="radio" name="rawDataModule-parser" value="ggir"/>
                  <span>ggir</span>
                </label>
                <label class="radio-inline">
                  <input type="radio" name="rawDataModule-parser" value="uncalibrated"/>
                  <span>uncalibrated</span>
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
                <select id="rawDataModule-axisRaw"><option value="X">X</option>
      <option value="Y">Y</option>
      <option value="Z">Z</option>
      <option value="Vector.Magnitude" selected>Vector.Magnitude</option></select>
                <script type="application/json" data-for="rawDataModule-axisRaw" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div id="rawDataModule-applyRaw" class="shiny-html-output"></div>
            <div id="rawDataModule-applyEpoch" class="shiny-html-output"></div>
            <h5><b>Plot Settings for Raw Data</b></h5>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="rawDataModule-gt3xPlotColor-label" for="rawDataModule-gt3xPlotColor">Plot Color (accepts color name or hex code)</label>
              <input id="rawDataModule-gt3xPlotColor" type="text" class="form-control" value="#000000"/>
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

