require 'spec_helper'
require 'gitsh/terminal'

describe Gitsh::Terminal do
  describe '#color_support?' do
    context 'on a 256 color terminal' do
      it 'returns true' do
        stub_tput_invocation output: "256\n"

        result = Gitsh::Terminal.instance.color_support?

        expect(result).to be_truthy
      end
    end

    context 'on a black and white terminal' do
      it 'returns false' do
        stub_tput_invocation output: "-1\n"

        result = Gitsh::Terminal.instance.color_support?

        expect(result).to be_falsey
      end
    end

    context 'when tput fails' do
      it 'returns false' do
        stub_tput_invocation error: "unknonwn capability\n", success: false

        result = Gitsh::Terminal.instance.color_support?

        expect(result).to be_falsey
      end
    end
  end

  context '#lines' do
    it 'returns the number of lines the terminal has' do
      stub_tput_invocation output: "24\n"

      result = Gitsh::Terminal.instance.lines

      expect(result).to eq 24
    end
  end

  context '#cols' do
    it 'returns the number of columns the terminal has' do
      stub_tput_invocation output: "80\n"

      result = Gitsh::Terminal.instance.cols

      expect(result).to eq 80
    end
  end

  def stub_tput_invocation(options = {})
    allow(Open3).to receive(:capture3).and_return [
      options.fetch(:output, ''),
      options.fetch(:error, ''),
      double('exit_status', success?: options.fetch(:success, true))
    ]
  end
end