# HalfTrend Indicator for MetaTrader 5

The **HalfTrend** indicator is a trend-following technical indicator for MetaTrader 5, designed to identify market trends and provide visual cues for traders and Expert Advisors (EAs). It plots a colored trend line (blue for uptrends, red for downtrends) and optional ATR-based channels to highlight potential support and resistance levels. Licensed under GPLv3, this indicator is ideal for traders seeking reliable trend signals and developers integrating trend data into automated trading systems.

## Features

- **Trend Detection**: Identifies uptrends and downtrends with a colored line (blue for up, red for down).
- **ATR Channels**: Optional dotted lines showing ATR-based high and low channels for volatility analysis.
- **EA Compatibility**: Dedicated buffers (`UpTrendBuffer` and `DownTrendBuffer`) for easy integration with Expert Advisors.
- **Customizable Parameters**: Adjust amplitude and channel deviation to suit different trading styles.
- **Lightweight and Efficient**: Optimized for real-time performance on MetaTrader 5.

## Installation

1. **Download**: Clone this repository or download the `HalfTrend.mq5` file.
2. **Compile**:
   - Open MetaTrader 5.
   - Navigate to **File > Open Data Folder > MQL5 > Indicators**.
   - Place `HalfTrend.mq5` in the Indicators folder.
   - In the MetaTrader 5 Navigator, right-click on Indicators and select **Refresh**.
3. **Apply**:
   - Open a chart in MetaTrader 5.
   - Drag the **HalfTrend** indicator from the Navigator onto the chart or double-click to apply.
   - Configure the input parameters as needed (see below).

## Usage

Once applied to a chart, the HalfTrend indicator will:
- Plot a solid trend line that switches between blue (uptrend) and red (downtrend) based on price action and moving average calculations.
- Optionally display dotted ATR channels (red for high, blue for low) to indicate volatility boundaries.
- Provide data through buffers 4 and 5 for EAs to access uptrend and downtrend values.

### Interpreting the Indicator
- **Blue Line**: Indicates an uptrend. Consider bullish strategies or use buffer 4 for EA buy signals.
- **Red Line**: Indicates a downtrend. Consider bearish strategies or use buffer 5 for EA sell signals.
- **ATR Channels**: Use these as dynamic support/resistance levels or to gauge volatility.

## Input Parameters

| Parameter            | Description                                      | Default Value |
|----------------------|--------------------------------------------------|---------------|
| `Amplitude`          | Period for calculating highest/lowest prices and SMA. Higher values smooth the trend. | 2             |
| `ChannelDeviation`   | Multiplier for ATR to set channel width. Higher values widen the channels. | 2             |
| `ShowChannels`       | Enable/disable ATR channels on the chart.         | true          |

## Example

To use HalfTrend on a 1-hour EURUSD chart:
1. Apply the indicator with default settings.
2. Observe the blue/red trend line to identify the current trend.
3. If `ShowChannels` is enabled, use the dotted lines to set stop-loss or take-profit levels.
4. For EAs, access `UpTrendBuffer` (buffer 4) for uptrend values and `DownTrendBuffer` (buffer 5) for downtrend values.

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). See the [LICENSE](LICENSE) file for details.

## Contact

For questions, suggestions, or support, contact the author at [pakrohk@gmail.com](mailto:pakrohk@gmail.com).

## Contributing

Contributions are welcome! Please fork the repository, make your changes, and submit a pull request. Ensure your code adheres to the GPLv3 license.
