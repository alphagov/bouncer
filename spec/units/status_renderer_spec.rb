require 'spec_helper'

describe StatusRenderer do
  subject(:renderer) { StatusRenderer.new }

  describe 'template storage' do
    its([404]) { should be_an(Erubis::Eruby) }
    its([410]) { should be_an(Erubis::Eruby) }
    its([301]) { should be_nil }

    it 'reuses its templates' do
      t1 = renderer[404]
      t2 = renderer[404]

      t1.object_id.should == t2.object_id
    end
  end

  describe 'template rendering' do
    let(:context) { RenderingContext.new(title: 'Keeping bees') }

    subject(:rendered) { renderer.render(context, 410) }

    it { should include('410 - Page Archived') }
    it { should include('Keeping bees') }
  end
end
