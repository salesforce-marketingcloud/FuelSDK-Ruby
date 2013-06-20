require 'spec_helper.rb'
require 'objects_helper_spec.rb'

describe FuelSDK::ET_BounceEvent do

  let(:object) { FuelSDK::ET_BounceEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'BounceEvent' }
end

describe FuelSDK::ET_ClickEvent do

  let(:object) { FuelSDK::ET_ClickEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ClickEvent' }
end

describe FuelSDK::ET_ContentArea do

  let(:object) { FuelSDK::ET_ContentArea.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'ContentArea' }
end

describe FuelSDK::ET_DataFolder do

  let(:object) { FuelSDK::ET_DataFolder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe FuelSDK::ET_Folder do

  let(:object) { FuelSDK::ET_Folder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe FuelSDK::ET_Email do

  let(:object) { FuelSDK::ET_Email.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Email' }
end

describe FuelSDK::ET_List do

  let(:object) { FuelSDK::ET_List.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'List' }
end

describe FuelSDK::ET_List::Subscriber do

  let(:object) { FuelSDK::ET_List::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ListSubscriber' }
end

describe FuelSDK::ET_OpenEvent do

  let(:object) { FuelSDK::ET_OpenEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'OpenEvent' }
end

describe FuelSDK::ET_SentEvent do

  let(:object) { FuelSDK::ET_SentEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'SentEvent' }
end
