require 'spec_helper.rb'
require 'objects_helper_spec.rb'

describe FuelSDK::BounceEvent do

  let(:object) { FuelSDK::BounceEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'BounceEvent' }
end

describe FuelSDK::ClickEvent do

  let(:object) { FuelSDK::ClickEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ClickEvent' }
end

describe FuelSDK::ContentArea do

  let(:object) { FuelSDK::ContentArea.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'ContentArea' }
end

describe FuelSDK::DataFolder do

  let(:object) { FuelSDK::DataFolder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe FuelSDK::Folder do

  let(:object) { FuelSDK::Folder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe FuelSDK::Email do

  let(:object) { FuelSDK::Email.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Email' }
end

describe FuelSDK::List do

  let(:object) { FuelSDK::List.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'List' }
end

describe FuelSDK::List::Subscriber do

  let(:object) { FuelSDK::List::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ListSubscriber' }
end

describe FuelSDK::OpenEvent do

  let(:object) { FuelSDK::OpenEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'OpenEvent' }
end

describe FuelSDK::SentEvent do

  let(:object) { FuelSDK::SentEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'SentEvent' }
end

describe FuelSDK::Subscriber do

  let(:object) { FuelSDK::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Subscriber' }
end

# verify backward compats
describe ET_Subscriber do

  let(:object) { ET_Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Subscriber' }
end
