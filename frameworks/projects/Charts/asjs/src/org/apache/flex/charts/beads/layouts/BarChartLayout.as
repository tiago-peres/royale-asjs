////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.charts.beads.layouts
{
	import org.apache.flex.charts.core.ICartesianChartLayout;
	import org.apache.flex.charts.core.IChartItemRenderer;
	import org.apache.flex.charts.core.IChartSeries;
	import org.apache.flex.charts.supportClasses.BarSeries;
	import org.apache.flex.core.IBeadLayout;
	import org.apache.flex.core.ISelectionModel;
	import org.apache.flex.core.IViewport;
	import org.apache.flex.core.IViewportModel;
	import org.apache.flex.core.UIBase;
	import org.apache.flex.events.Event;
	import org.apache.flex.events.IEventDispatcher;
	
	/**
	 *  The BarChartLayout class calculates the size and position of all of the itemRenderers for
	 *  all of the series in a BarChart. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion FlexJS 0.0
	 */
	public class BarChartLayout extends ChartBaseLayout implements IBeadLayout, ICartesianChartLayout
	{
		/**
		 *  constructor.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function BarChartLayout()
		{
			super();
		}
		
		private var _gap:Number = 20;
		
		/**
		 *  The amount of space to leave between series. If a chart has several series,
		 *  the bars for an X value are side by side with a gap between the groups of
		 *  bars.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion FlexJS 0.0
		 */
		public function get gap():Number
		{
			return _gap;
		}
		public function set gap(value:Number):void
		{
			_gap = value;
		}
		
		/**
		 * @private
		 */
		override protected function performLayout():void
		{			
			var selectionModel:ISelectionModel = chart.getBeadByType(ISelectionModel) as ISelectionModel;
			var dp:Array = selectionModel.dataProvider as Array;
			if (!dp)
				return;
			
			// this layout will use and modify the IViewportMode
			var viewport:IViewport = chart.getBeadByType(IViewport) as IViewport;
			var viewportModel:IViewportModel = viewport.model;
			
			var n:int = dp.length;
			var useWidth:Number = viewportModel.contentWidth;
			var useHeight:Number = viewportModel.contentHeight;
			var itemHeight:Number =  (useHeight - gap*(dp.length-1))/dp.length;
			var seriesHeight:Number = itemHeight/chart.series.length;
			var ypos:Number = useHeight;
			
			var maxXValue:Number = 0;
			var minXValue:Number = 0;
			var scaleFactor:Number = 1.0;
			var determineScale:Boolean = true;
			
			if (horizontalAxisBead != null && !isNaN(horizontalAxisBead.maximum)) {
				maxXValue = horizontalAxisBead.maximum;
				determineScale = false;
			}
			if (horizontalAxisBead != null && !isNaN(horizontalAxisBead.minimum)) {
				minXValue = horizontalAxisBead.minimum;
			}
			
			for (var s:int = 0; s < chart.series.length; s++)
			{
				var bcs:BarSeries = chart.series[s] as BarSeries;
				
				for (var i:int = 0; i < n; i++)
				{
					var data:Object = dp[i];
					var field:String = bcs.xField;
					
					var xValue:Number = Number(data[field]);
					if (determineScale) maxXValue = Math.max(xValue, maxXValue);
				}				
			}
			
			var range:Number = maxXValue - minXValue;
			scaleFactor = useWidth/range;
			
			for (i = 0; i < n; i++)
			{
				data = dp[i];
				
				for (s=0; s < chart.series.length; s++)
				{
					bcs = chart.series[s] as BarSeries;
					
					var child:IChartItemRenderer = chartDataGroup.getItemRendererForSeriesAtIndex(bcs,i);
					xValue = Number(data[bcs.xField]) - minXValue;
					if (xValue > maxXValue) xValue = maxXValue;
					xValue = xValue * scaleFactor;
					
					child.x = 0;
					child.y = ypos - seriesHeight;
					child.width = xValue;
					child.height = seriesHeight;
					ypos -= seriesHeight;
				}
				
				ypos -= gap;
			}
			
			IEventDispatcher(chart).dispatchEvent(new Event("layoutComplete"));
		}
	}
}