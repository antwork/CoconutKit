//
//  CursorCustomPointerView.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface CursorCustomPointerView : HLSXibView {
@private
    UILabel *m_valueLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *valueLabel;

@end
