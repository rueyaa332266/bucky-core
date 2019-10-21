# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/user_operation/user_operation_helper'
require 'selenium-webdriver'

describe Bucky::TestEquipment::UserOperation::UserOperationHelper do
  let(:driver_double) { double('driver double') }
  let(:pages_double) { double('pages double') }
  let(:user_operation_helpr_args) { { service: 'sample_app', device: 'pc', driver: driver_double, pages: pages_double } }

  subject { Bucky::TestEquipment::UserOperation::UserOperationHelper.new(user_operation_helpr_args) }

  describe '#go' do
    let(:operation) { :go }
    let(:args) { { url: 'http://example.com' } }
    it 'call driver.navigate' do
      expect(driver_double).to receive_message_chain(:navigate, :to)
      subject.send(operation, args)
    end
  end

  describe '#back' do
    let(:operation) { :back }
    it 'call driver.navigate.back' do
      expect(driver_double).to receive_message_chain(:navigate, :back)
      subject.send(operation, nil)
    end
  end

  describe '#refresh' do
    let(:operation) { :refresh }
    it 'call driver.navigate.refresh' do
      expect(driver_double).to receive_message_chain(:navigate, :refresh)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_next_window' do
    let(:operation) { :switch_to_next_window }
    let(:window_index) { 2 }
    before do
      allow(driver_double).to receive(:window_handle)
      allow(driver_double).to receive_message_chain(:window_handles, :index).and_return(window_index)
    end
    it 'call driver.switch_to.window' do
      allow(driver_double).to receive_message_chain(:window_handles, :[])
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, nil)
    end

    it 'switch to next window index' do
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive_message_chain(:window_handles, :[]).with(window_index+1)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_last_window' do
    let(:operation) { :switch_to_last_window }
    let(:window_index) { 2 }
    before do
      allow(driver_double).to receive(:window_handle)
      allow(driver_double).to receive_message_chain(:window_handles, :index).and_return(window_index)
    end
    it 'call driver.switch_to.window' do
      allow(driver_double).to receive_message_chain(:window_handles, :[])
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, nil)
    end

    it 'switch to last window index' do
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive_message_chain(:window_handles, :[]).with(window_index-1)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_the_window' do
    let(:operation) { :switch_to_the_window }
    let(:args) { { window_name: 'new' } }
    it 'call driver.swich_to_window_by_name' do
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, args)
    end
    it 'call wait_until_helper' do
      expect(subject).to receive(:wait_until_helper)
      subject.send(operation, args)
    end
  end

  describe '#close' do
    let(:operation) { :close }
    let(:window_index) { 2 }
    before do
      allow(driver_double).to receive(:window_handle)
      allow(driver_double).to receive_message_chain(:window_handles, :index).and_return(window_index)
    end
    it 'call driver.close' do
      allow(driver_double).to receive_message_chain(:window_handles, :[])
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive(:close)
      subject.send(operation, nil)
    end

    it 'switch to last window index' do
      allow(driver_double).to receive(:close)
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive_message_chain(:window_handles, :[]).with(window_index-1)
      subject.send(operation, nil)
    end
  end

  describe '#stop' do
    let(:operation) { :stop }
    it 'call gets' do
      expect(subject).to receive(:gets)
      subject.send(operation, nil)
    end
  end

  describe '#input' do
    let(:operation) { :input }
    let(:args) { { page: 'top', part: 'form', word: 'hogehoge' } }
    let(:elem_double) { double('elem double') }
    it 'call part#send_keys' do
      expect(pages_double).to receive_message_chain(:get_part, :send_keys)
      subject.send(operation, args)
    end
    it 'call wait_until_helper' do
      allow(pages_double).to receive_message_chain(:get_part, :send_keys).and_return(elem_double)
      expect(subject).to receive(:wait_until_helper)
      subject.send(operation, args)
    end
  end

  describe '#clear' do
    let(:operation) { :clear }
    let(:args) { { page: 'top', part: 'form' } }
    it 'call part#clear' do
      expect(pages_double).to receive_message_chain(:get_part, :clear)
      subject.send(operation, args)
    end
  end

  describe '#click' do
    let(:operation) { :click }
    let(:args) { { page: 'top', part: 'form' } }
    let(:elem_double) { double('elem double') }
    it 'call part#click' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(elem_double).to receive(:location_once_scrolled_into_view)
      expect(elem_double).to receive(:click)
      subject.send(operation, args)
    end
    it 'call part#location_once_scrolled_into_view' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(elem_double).to receive(:click)
      expect(elem_double).to receive(:location_once_scrolled_into_view)
      subject.send(operation, args)
    end
    it 'call wait_until_helper' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(elem_double).to receive(:click)
      allow(elem_double).to receive(:location_once_scrolled_into_view)
      expect(subject).to receive(:wait_until_helper)
      subject.send(operation, args)
    end
  end

  describe '#choose' do
    let(:operation) { :choose }
    let(:args_text) { { page: 'top', part: 'form', text: 'foo' } }
    let(:args_value) { { page: 'top', part: 'form', value: 1 } }
    let(:args_index) { { page: 'top', part: 'form', index: 1 } }
    let(:args_error) { { page: 'top', part: 'form', error: 1 } }
    let(:option_double) { double('option double') }
    let(:elem_double) { double('elem double') }
    before do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(Selenium::WebDriver::Support::Select).to receive(:new).with(elem_double).and_return(option_double)
    end
    it 'when there is text in keys, call driver.support.select.select_by with text' do
      expect(option_double).to receive(:select_by).with(:text, 'foo')
      subject.send(operation, args_text)
    end
    it 'when there is value in keys, call driver.support.select.select_by with value' do
      expect(option_double).to receive(:select_by).with(:value, '1')
      subject.send(operation, args_value)
    end
    it 'when there is index in keys, call driver.support.select.select_by with index' do
      expect(option_double).to receive(:select_by).with(:index, 1)
      subject.send(operation, args_index)
    end
    it 'if there is undefined key, raise exception' do
      expect { subject.send(operation, args_error) }.to raise_error(StandardError, 'Included invalid key [:page, :part, :error]')
    end
    it 'call wait_until_helper' do
      allow(option_double).to receive(:select_by).with(:text, 'foo')
      expect(subject).to receive(:wait_until_helper).and_return(option_double)
      subject.send(operation, args_text)
    end
  end

  describe '#accept_alert' do
    let(:operation) { :accept_alert }
    let(:alert_double) { double('alert double') }
    it 'call driver.switch_to.alert.accept' do
      expect(driver_double).to receive_message_chain(:switch_to, :alert, :accept)
      subject.send(operation, nil)
    end
    it 'call wait_until_helper' do
      allow(driver_double).to receive_message_chain(:switch_to, :alert).and_return(alert_double)
      allow(alert_double).to receive(:accept)
      expect(subject).to receive(:wait_until_helper).and_return(alert_double)
      subject.send(operation, nil)
    end
  end

  describe '#wait' do
    let(:operation) { :wait }
    let(:args) { { sec: 1 } }
    it 'call sleep' do
      expect(subject).to receive(:sleep)
      subject.send(operation, args)
    end
  end
end
