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
                    <input id="compareCountsModule-agdFile" name="compareCountsModule-agdFile" type="file" style="position: absolute !important; top: -99999px !important; left: -99999px !important;" accept=".agd"/>
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
                <select id="compareCountsModule-axisCounts2"><option value="Axis1">Axis1</option>
      <option value="Axis2">Axis2</option>
      <option value="Axis3">Axis3</option>
      <option value="Vector.Magnitude" selected>Vector.Magnitude</option></select>
                <script type="application/json" data-for="compareCountsModule-axisCounts2" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="compareCountsModule-agdBlandAltmanPlot" type="checkbox"/>
                  <span>Bland Altman Plot?</span>
                </label>
              </div>
            </div>
            <div id="compareCountsModule-rangeYBlandAltman" class="shiny-html-output"></div>
            <div class="form-group shiny-input-container">
              <label class="control-label" id="compareCountsModule-agdPlotColor-label" for="compareCountsModule-agdPlotColor">Plot Color (accepts color name or hex code)</label>
              <input id="compareCountsModule-agdPlotColor" type="text" class="form-control" value="#000000"/>
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

