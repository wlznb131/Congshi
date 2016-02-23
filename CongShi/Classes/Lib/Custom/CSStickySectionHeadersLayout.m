//
//  CSStickySectionHeadersLayout.m
//  CongShi
//
//  Created by Archy on 16/1/20.
//  Copyright © 2016年 Archy. All rights reserved.
//

#import "CSStickySectionHeadersLayout.h"

@implementation CSStickySectionHeadersLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    NSMutableArray *visibleSectionsWithoutHeader = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
        if (![visibleSectionsWithoutHeader containsObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]]) {
            [visibleSectionsWithoutHeader addObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]];
        }
        if (itemAttributes.representedElementKind==UICollectionElementKindSectionHeader) {
            NSUInteger indexOfSectionObject=[visibleSectionsWithoutHeader indexOfObject:[NSNumber numberWithInteger:itemAttributes.indexPath.section]];
            if (indexOfSectionObject!=NSNotFound) {
                [visibleSectionsWithoutHeader removeObjectAtIndex:indexOfSectionObject];
            }
        }
    }
    for (NSNumber *sectionNumber in visibleSectionsWithoutHeader) {
        if ([self stickySectionHeadesLayout:self shouldStickHeaderToTopInSection:[sectionNumber integerValue]]) {
            UICollectionViewLayoutAttributes *headerAttributes=[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:[sectionNumber integerValue]]];
            if (headerAttributes.frame.size.width>0 && headerAttributes.frame.size.height>0) {
                [attributes addObject:headerAttributes];
            }
        }
    }
    for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
        if (itemAttributes.representedElementKind==UICollectionElementKindSectionHeader) {
            UICollectionViewLayoutAttributes *headerAttributes = itemAttributes;
            if ([self stickySectionHeadesLayout:self shouldStickHeaderToTopInSection:headerAttributes.indexPath.section]) {
                CGPoint contentOffset = self.collectionView.contentOffset;
                CGPoint originInCollectionView=CGPointMake(headerAttributes.frame.origin.x-contentOffset.x, headerAttributes.frame.origin.y-contentOffset.y);
                originInCollectionView.y-=self.collectionView.contentInset.top;
                CGRect frame = headerAttributes.frame;
                if (originInCollectionView.y<0) {
                    frame.origin.y+=(originInCollectionView.y*-1);
                }
                NSInteger numberOfSections = 1;
                if ([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
                    numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
                }
                if (numberOfSections>headerAttributes.indexPath.section+1) {
                    UICollectionViewLayoutAttributes *nextHeaderAttributes=[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:headerAttributes.indexPath.section+1]];
                    CGFloat maxY=nextHeaderAttributes.frame.origin.y;
                    if (CGRectGetMaxY(frame)>=maxY) {
                        frame.origin.y=maxY-frame.size.height;
                    }
                }
                headerAttributes.frame = frame;
            }
            headerAttributes.zIndex = 1024;
        }
    }
    return attributes;
}

- (BOOL)stickySectionHeadesLayout:(CSStickySectionHeadersLayout *)layout shouldStickHeaderToTopInSection:(NSUInteger)section;
{
    BOOL shouldStickToTop=YES;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(CSStickySectionHeadersLayoutDelegate)]) {
        id<CSStickySectionHeadersLayoutDelegate> stickyHeadersDelegate=(id<CSStickySectionHeadersLayoutDelegate>)self.collectionView.delegate;
        if ([stickyHeadersDelegate respondsToSelector:@selector(stickySectionHeadesLayout:shouldStickHeaderToTopInSection:)]) {
            shouldStickToTop=[stickyHeadersDelegate stickySectionHeadesLayout:self shouldStickHeaderToTopInSection:section];
        }
    }
    return shouldStickToTop;

}
@end
