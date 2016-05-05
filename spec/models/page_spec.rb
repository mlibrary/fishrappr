require 'rails_helper'

describe Page do
  let(:page) { described_class.new }

  it { should respond_to(:get_full_text) }
  it { should respond_to(:remove_from_index) }

end
